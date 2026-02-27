# frozen_string_literal: true

require "waterdrop"
require "karafka/testing"
require "karafka/testing/errors"
require "karafka/testing/helpers"
require "karafka/testing/spec_consumer_client"
require "karafka/testing/spec_producer_client"
require "karafka/testing/rspec/proxy"

module Karafka
  module Testing
    # All the things related to extra functionalities needed to easier spec out
    # Karafka things using RSpec
    module RSpec
      # RSpec helpers module that needs to be included
      module Helpers
        # Map to convert dispatch attributes into their "delivery" format, since we bypass Kafka
        METADATA_DISPATCH_MAPPINGS = {
          raw_key: :key,
          raw_headers: :headers
        }.freeze

        private_constant :METADATA_DISPATCH_MAPPINGS

        class << self
          # Adds all the needed extra functionalities to the rspec group
          # @param base [Class] RSpec example group we want to extend
          def included(base)
            # RSpec local reference to Karafka proxy that allows us to build the consumer instance
            base.let(:karafka) { Karafka::Testing::RSpec::Proxy.new(self) }

            # Messages that are targeted to the consumer
            # You can produce many messages from Karafka during specs and not all should go to the
            # consumer for processing. This buffer holds only those that should go to consumer
            base.let(:_karafka_consumer_messages) { [] }
            # Consumer fake client to mock communication with Kafka
            base.let(:_karafka_consumer_client) { Karafka::Testing::SpecConsumerClient.new }
            # Producer fake client to mock communication with Kafka
            base.let(:_karafka_producer_client) { Karafka::Testing::SpecProducerClient.new(self) }

            base.before(:context) do
              Karafka::Testing.ensure_karafka_initialized!
              @_karafka_shared_producer_client = WaterDrop::Clients::Dummy.new(-1)
              Karafka.producer.instance_variable_set(:@client, @_karafka_shared_producer_client)
              Karafka.producer.instance_variable_set(:@pid, ::Process.pid)
            end

            base.prepend_before do
              _karafka_consumer_messages.clear
              _karafka_producer_client.reset
              @_karafka_consumer_mappings = {}

              # We do check the presence not only of Mocha but also that it is used and
              # that patches are available because some users have Mocha as part of their
              # supply chain, but do not use it when running Karafka specs. In such cases, without
              # such check `karafka-testing` would falsely assume, that Mocha is in use.
              if Object.const_defined?("Mocha", false) && Karafka.producer.respond_to?(:stubs)
                Karafka.producer.stubs(:client).returns(_karafka_producer_client)
              else
                allow(Karafka.producer).to receive(:client).and_return(_karafka_producer_client)
              end
            end
          end
        end

        # Creates a consumer instance for a given topic
        #
        # @param requested_topic [String, Symbol] name of the topic for which we want to
        #   create a consumer instance
        # @param requested_consumer_group [String, Symbol, nil] optional name of the consumer group
        #   if we have multiple consumer groups listening on the same topic
        # @return [Object] Karafka consumer instance
        # @raise [Karafka::Testing::Errors::TopicNotFoundError] raised when we're unable to find
        #   topic that was requested
        #
        # @example Creates a MyConsumer consumer instance with settings for `my_requested_topic`
        #   RSpec.describe MyConsumer do
        #     subject(:consumer) { karafka.consumer_for(:my_requested_topic) }
        #   end
        def _karafka_consumer_for(requested_topic, requested_consumer_group = nil)
          selected_topics = Testing::Helpers.karafka_consumer_find_candidate_topics(
            requested_topic.to_s,
            requested_consumer_group.to_s
          )

          raise Errors::TopicInManyConsumerGroupsError, requested_topic if selected_topics.size > 1
          raise Errors::TopicNotFoundError, requested_topic if selected_topics.empty?

          _karafka_build_consumer_for(selected_topics.first)
        end

        # Adds a new Karafka message instance if needed with given payload and options into an
        # internal consumer buffer that will be used to simulate messages delivery to the consumer
        #
        # @param message [Hash] message that was sent to Kafka
        # @example Send a json message to consumer
        #   before do
        #     karafka.produce({ 'hello' => 'world' }.to_json)
        #   end
        #
        # @example Send a json message to consumer and simulate, that it is partition 6
        #   before do
        #     karafka.produce({ 'hello' => 'world' }.to_json, 'partition' => 6)
        #   end
        def _karafka_add_message_to_consumer_if_needed(message)
          consumer_obj = if defined?(consumer)
            consumer
          else
            _karafka_find_consumer_for_message(message)
          end
          # Consumer needs to be defined in order to pass messages to it
          return unless consumer_obj
          # We're interested in adding message to consumer only when it is a Karafka consumer
          # Users may want to test other things (models producing messages for example) and in
          # their case consumer will not be a consumer
          return unless consumer_obj.is_a?(Karafka::BaseConsumer)
          # We target to the consumer only messages that were produced to it, since specs may also
          # produce other messages targeting other topics
          return unless message[:topic] == consumer_obj.topic.name
          # If consumer_group is explicitly specified, verify it matches
          return if message[:consumer_group] &&
            message[:consumer_group].to_s != consumer_obj.topic.consumer_group.name

          # Build message metadata and copy any metadata that would come from the message
          metadata = _karafka_message_metadata_defaults(consumer_obj)

          metadata.keys.each do |key|
            message_key = METADATA_DISPATCH_MAPPINGS.fetch(key, key)

            next unless message.key?(message_key)

            metadata[key] = message.fetch(message_key)
          end

          # Add this message to previously produced messages
          _karafka_consumer_messages << Karafka::Messages::Message.new(
            message[:payload],
            Karafka::Messages::Metadata.new(metadata)
          )

          # Update batch metadata
          batch_metadata = Karafka::Messages::Builders::BatchMetadata.call(
            _karafka_consumer_messages,
            consumer_obj.topic,
            0,
            Time.now
          )

          # Update consumer messages batch
          consumer_obj.messages = Karafka::Messages::Messages.new(
            _karafka_consumer_messages,
            batch_metadata
          )
        end

        # Produces message with a given payload to the consumer matching topic
        # @param payload [String] payload we want to dispatch
        # @param metadata [Hash] any metadata we want to dispatch alongside the payload.
        #   Supports an `offset` key to set a custom offset for the message (otherwise
        #   offsets auto-increment from 0).
        def _karafka_produce(payload, metadata = {})
          # Extract offset before passing to WaterDrop since it is not a valid
          # WaterDrop message attribute (Kafka assigns offsets, not producers)
          @_karafka_next_offset = metadata.delete(:offset)

          topic = if metadata[:topic]
            metadata[:topic]
          elsif defined?(consumer)
            consumer.topic.name
          else
            last_consumer = @_karafka_consumer_mappings&.values&.last
            last_consumer&.topic&.name
          end
          Karafka.producer.produce_sync(
            {
              topic: topic,
              payload: payload
            }.merge(metadata)
          )
        ensure
          @_karafka_next_offset = nil
        end

        # @return [Array<Hash>] messages that were produced
        def _karafka_produced_messages
          _karafka_producer_client.messages
        end

        # Produces message to a specific consumer instance
        # Use when testing multiple consumers for the same topic
        #
        # @param consumer_instance [Object] the consumer to produce to
        # @param payload [String] message content (usually serialized JSON) to deliver to the
        #   consumer
        # @param metadata [Hash] any metadata to dispatch alongside the payload
        #
        # @example Produce to specific consumer when multiple exist for same topic
        #   let(:consumer1) { karafka.consumer_for(:events, :analytics_group) }
        #   let(:consumer2) { karafka.consumer_for(:events, :notifications_group) }
        #
        #   before do
        #     karafka.produce_to(consumer1, { 'event' => 'click' }.to_json)
        #   end
        def _karafka_produce_to(consumer_instance, payload, metadata = {})
          _karafka_produce(
            payload,
            metadata.merge(
              topic: consumer_instance.topic.name,
              consumer_group: consumer_instance.topic.consumer_group.name
            )
          )
        end

        private

        # Finds a consumer for the given message with backward-compatible fallback
        # @param message [Hash] the message being routed
        # @return [Object, nil] the consumer instance or nil
        def _karafka_find_consumer_for_message(message)
          return nil unless @_karafka_consumer_mappings

          topic_name = message[:topic]
          consumer_group = message[:consumer_group]

          if consumer_group
            # Explicit consumer group - find by composite key pattern
            @_karafka_consumer_mappings.values.find do |c|
              c.topic.name == topic_name && c.topic.consumer_group.name == consumer_group.to_s
            end
          else
            # No consumer group specified - find all consumers for this topic
            matching = @_karafka_consumer_mappings.values.select { |c| c.topic.name == topic_name }
            # If exactly one consumer matches, use it (backward compatible)
            (matching.size == 1) ? matching.first : nil
          end
        end

        # @param consumer_obj [Karafka::BaseConsumer] consumer reference
        # @return [Hash] message default options
        def _karafka_message_metadata_defaults(consumer_obj)
          {
            deserializers: consumer_obj.topic.deserializers,
            timestamp: Time.now,
            raw_headers: {},
            raw_key: nil,
            offset: @_karafka_next_offset.nil? ? _karafka_consumer_messages.size : @_karafka_next_offset,
            partition: 0,
            received_at: Time.now,
            topic: consumer_obj.topic.name
          }
        end

        # Builds the consumer instance based on the provided topic
        #
        # @param topic [Karafka::Routing::Topic] topic for which we want to build the consumer
        # @return [Object] karafka consumer
        def _karafka_build_consumer_for(topic)
          coordinators = Karafka::Processing::CoordinatorsBuffer.new(
            Karafka::Routing::Topics.new([topic])
          )

          processing_cfg = Karafka::App.config.internal.processing
          consumer = topic.consumer.new
          consumer.producer = Karafka::App.producer
          # Inject appropriate strategy so needed options and components are available
          strategy = processing_cfg.strategy_selector.find(topic)
          consumer.singleton_class.include(strategy)
          consumer.client = _karafka_consumer_client
          consumer.coordinator = coordinators.find_or_create(topic.name, 0)
          consumer.coordinator.seek_offset = 0
          # Indicate usage as for tests no direct enqueuing happens
          consumer.instance_variable_set(:@used, true)
          expansions = processing_cfg.expansions_selector.find(topic)
          expansions.each { |expansion| consumer.singleton_class.include(expansion) }

          @_karafka_consumer_mappings[topic.id] = consumer
          consumer
        end
      end
    end
  end
end
