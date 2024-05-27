# frozen_string_literal: true

require 'karafka/testing'
require 'karafka/testing/errors'
require 'karafka/testing/helpers'
require 'karafka/testing/spec_consumer_client'
require 'karafka/testing/spec_producer_client'
require 'karafka/testing/minitest/proxy'

module Karafka
  module Testing
    # All the things related to extra functionalities needed to easier spec out
    # Karafka things using Minitest
    module Minitest
      # Minitest helpers module that needs to be included
      module Helpers
        # Map to convert dispatch attributes into their "delivery" format, since we bypass Kafka
        METADATA_DISPATCH_MAPPINGS = {
          raw_key: :key,
          raw_headers: :headers
        }.freeze

        private_constant :METADATA_DISPATCH_MAPPINGS

        class << self
          # Adds all the needed extra functionalities to the minitest group
          # @param base [Class] Minitest example group we want to extend
          def included(base)
            eval_flow = lambda do
              Karafka::Testing.ensure_karafka_initialized!

              @karafka = Karafka::Testing::Minitest::Proxy.new(self)
              @_karafka_consumer_messages = []
              @_karafka_consumer_client = Karafka::Testing::SpecConsumerClient.new
              @_karafka_producer_client = Karafka::Testing::SpecProducerClient.new(self)

              @_karafka_consumer_messages.clear
              @_karafka_producer_client.reset

              @_karafka_consumer_mappings = {}

              Karafka.producer.stubs(:client).returns(@_karafka_producer_client)
            end

            if base.to_s == 'Minitest::Spec'
              base.class_eval do
                before(&eval_flow)
              end
            else
              base.class_eval do
                setup(&eval_flow)
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
        # @example Creates a consumer instance with settings for `my_requested_topic`
        #   consumer = @karafka.consumer_for(:my_requested_topic)
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
        #
        # @example Send a json message to consumer
        #   @karafka.produce({ 'hello' => 'world' }.to_json)
        #
        # @example Send a json message to consumer and simulate, that it is partition 6
        #   @karafka.produce({ 'hello' => 'world' }.to_json, 'partition' => 6)
        def _karafka_add_message_to_consumer_if_needed(message)
          consumer_obj = if defined?(@consumer)
                           @consumer
                         else
                           @_karafka_consumer_mappings&.dig(message[:topic])
                         end
          # Consumer needs to be defined in order to pass messages to it
          return unless defined?(consumer_obj)
          # We're interested in adding message to consumer only when it is a Karafka consumer
          # Users may want to test other things (models producing messages for example) and in
          # their case consumer will not be a consumer
          return unless consumer_obj.is_a?(Karafka::BaseConsumer)
          # We target to the consumer only messages that were produced to it, since specs may also
          # produce other messages targeting other topics
          return unless message[:topic] == consumer_obj.topic.name

          # Build message metadata and copy any metadata that would come from the message
          metadata = _karafka_message_metadata_defaults(consumer_obj)

          metadata.keys.each do |key|
            message_key = METADATA_DISPATCH_MAPPINGS.fetch(key, key)

            next unless message.key?(message_key)

            metadata[key] = message.fetch(message_key)
          end

          # Add this message to previously produced messages
          @_karafka_consumer_messages << Karafka::Messages::Message.new(
            message[:payload],
            Karafka::Messages::Metadata.new(metadata)
          )
          # Update batch metadata
          batch_metadata = Karafka::Messages::Builders::BatchMetadata.call(
            @_karafka_consumer_messages,
            consumer_obj.topic,
            0,
            Time.now
          )

          # Update consumer messages batch
          consumer_obj.messages = Karafka::Messages::Messages.new(
            @_karafka_consumer_messages,
            batch_metadata
          )
        end

        # Produces message with a given payload to the consumer matching topic
        # @param payload [String] payload we want to dispatch
        # @param metadata [Hash] any metadata we want to dispatch alongside the payload
        def _karafka_produce(payload, metadata = {})
          topic = if metadata[:topic]
                    metadata[:topic]
                  elsif defined?(@consumer)
                    @consumer.topic.name
                  else
                    @_karafka_consumer_mappings&.keys&.last
                  end
          Karafka.producer.produce_sync(
            {
              topic: topic,
              payload: payload
            }.merge(metadata)
          )
        end

        # @return [Array<Hash>] messages that were produced
        def _karafka_produced_messages
          @_karafka_producer_client.messages
        end

        private

        # @return [Hash] message default options
        def _karafka_message_metadata_defaults(consumer_obj)
          {
            deserializers: consumer_obj.topic.deserializers,
            timestamp: Time.now,
            raw_headers: {},
            raw_key: nil,
            offset: @_karafka_consumer_messages.size,
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
          @consumer = topic.consumer.new
          @consumer.producer = Karafka::App.producer
          # Inject appropriate strategy so needed options and components are available
          strategy = Karafka::App.config.internal.processing.strategy_selector.find(topic)
          @consumer.singleton_class.include(strategy)
          @consumer.client = @_karafka_consumer_client
          @consumer.coordinator = coordinators.find_or_create(topic.name, 0)
          @consumer.coordinator.seek_offset = 0
          # Indicate usage as for tests no direct enqueuing happens
          @consumer.instance_variable_set('@used', true)
          @_karafka_consumer_mappings[topic.name] = @consumer
          @consumer
        end
      end
    end
  end
end
