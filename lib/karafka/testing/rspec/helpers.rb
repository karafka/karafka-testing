# frozen_string_literal: true

require 'karafka/testing/errors'
require 'karafka/testing/dummy_client'
require 'karafka/testing/rspec/proxy'

module Karafka
  module Testing
    # All the things related to extra functionalities needed to easier spec out
    # Karafka things using RSpec
    module RSpec
      # RSpec helpers module that needs to be included
      module Helpers
        class << self
          # Adds all the needed extra functionalities to the rspec group
          # @param base [Class] RSpec example group we want to extend
          def included(base)
            # This is an internal buffer for keeping "to be sent" messages before
            # we run the consume
            base.let(:_karafka_messages) { [] }
            base.let(:karafka) { Karafka::Testing::RSpec::Proxy.new(self) }
            # Clear the messages buffer after each spec, so nothing leaks in between them
            base.after { _karafka_messages.clear }
          end
        end

        # Creates a consumer instance for a given topic
        #
        # @param requested_topic [String, Symbol] name of the topic for which we want to
        #   create a consumer instance
        # @param requested_consumer_group [String, Symbol, nil] optional name of the consumer group
        #   if we have multiple consumer groups listening on the same topic
        # @return [Object] described_class instance
        # @raise [Karafka::Testing::Errors::TopicNotFoundError] raised when we're unable to find
        #   topic that was requested
        #
        # @example Creates a MyConsumer consumer instance with settings for `my_requested_topic`
        #   RSpec.describe MyConsumer do
        #     subject(:consumer) { karafka.consumer_for(:my_requested_topic) }
        #   end
        def karafka_consumer_for(requested_topic, requested_consumer_group = nil)
          selected_topics = []

          ::Karafka::App.consumer_groups.each do |consumer_group|
            consumer_group.topics.each do |topic|
              next if topic.name != requested_topic.to_s
              next if requested_consumer_group &&
                      consumer_group.name != requested_consumer_group.to_s

              selected_topics << topic
            end
          end

          raise Errors::TopicInManyConsumerGroupsError, requested_topic if selected_topics.size > 1
          raise Errors::TopicNotFoundError, requested_topic if selected_topics.empty?

          karafka_build_consumer_for(selected_topics.first)
        end

        # Adds a new Karafka message instance with given payload and options into an internal
        # buffer that will be used to simulate messages delivery to the consumer
        #
        # @param payload [String] anything you want to send
        # @param opts [Hash] additional options with which you want to overwrite the
        #   message defaults (key, offset, etc)
        #
        # @example Send a json message to consumer
        #   before do
        #     karafka.publish({ 'hello' => 'world' }.to_json)
        #   end
        #
        # @example Send a json message to consumer and simulate, that it is partition 6
        #   before do
        #     karafka.publish({ 'hello' => 'world' }.to_json, 'partition' => 6)
        #   end
        def karafka_publish(payload, opts = {})
          metadata = Karafka::Messages::Metadata.new(
            **karafka_message_metadata_defaults.merge(opts)
          ).freeze

          # Add this message to previously published messages
          _karafka_messages << Karafka::Messages::Message.new(payload, metadata)

          # Update batch metadata
          batch_metadata = Karafka::Messages::Builders::BatchMetadata.call(
            _karafka_messages,
            subject.topic,
            Time.now
          )

          # Update consumer messages batch
          subject.messages = Karafka::Messages::Messages.new(_karafka_messages, batch_metadata)
        end

        private

        # @return [Hash] message default options
        def karafka_message_metadata_defaults
          {
            deserializer: subject.topic.deserializer,
            timestamp: Time.now,
            headers: {},
            key: nil,
            offset: _karafka_messages.size,
            partition: 0,
            received_at: Time.now,
            topic: subject.topic.name
          }
        end

        # Builds the consumer instance based on the provided topic
        #
        # @param topic [Karafka::Routing::Topic] topic for which we want to build the consumer
        # @return [Object] karafka consumer
        def karafka_build_consumer_for(topic)
          coordinators = Karafka::Processing::CoordinatorsBuffer.new

          consumer = described_class.new
          consumer.topic = topic
          consumer.producer = Karafka::App.producer
          consumer.client = Karafka::Testing::DummyClient.new
          consumer.coordinator = coordinators.find_or_create(topic.name, 0)
          consumer
        end
      end
    end
  end
end
