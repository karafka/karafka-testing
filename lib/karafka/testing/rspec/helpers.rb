# frozen_string_literal: true

require 'karafka/testing/errors'

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
            base.let(:_karafka_raw_data) { [] }
            # Clear the messages buffer after each spec, so nothing will leak
            # in between them
            base.after { _karafka_raw_data.clear }
          end
        end

        # Creates a consumer instance for given topic
        # @param requested_topic [String, Symbol] name of the topic for which we want to
        #   create a consumer instance
        # @return [Object] described_class instance
        # @raise [Karafka::Testing::Errors::TopicNotFoundError] raised when we're unable to find
        #   topic that was requested
        #
        # @example Creates a MyConsumer consumer instance with settings for `my_requested_topic`
        #   RSpec.describe MyConsumer do
        #     subject(:consumer) { karafka_consumer_for(:my_requested_topic) }
        #   end
        def karafka_consumer_for(requested_topic)
          selected_topic = nil

          App.consumer_groups.each do |consumer_group|
            consumer_group.topics.each do |topic|
              selected_topic = topic if topic.name == requested_topic.to_s
            end
          end

          raise Karafka::Testing::Errors::TopicNotFoundError, requested_topic unless selected_topic

          described_class.new(selected_topic)
        end

        # Adds a new Karafka params instance with given payload and options into an internal
        # buffer that will be used to simulate messages delivery to the consumer
        #
        # @param payload [String] anything you want to send
        # @param opts [Hash] additional options with which you want to overwrite the
        #   message defaults (key, offset, etc)
        #
        # @example Send a json message to consumer
        #   before do
        #     publish_for_karafka({ 'hello' => 'world' }.to_json)
        #   end
        #
        # @example Send a json message to consumer and simulate, that it is partition 6
        #   before do
        #     publish_for_karafka({ 'hello' => 'world' }.to_json, 'partition' => 6)
        #   end
        def publish_for_karafka(payload, opts = {})
          _karafka_raw_data << Karafka::Params::Params
                               .new
                               .merge!(message_defaults)
                               .merge!('payload' => payload)
                               .merge!(opts)

          subject.params_batch = Karafka::Params::ParamsBatch
                                 .new(_karafka_raw_data)
        end

        private

        # @return [Hash] message default options
        def message_defaults
          {
            'deserializer' => subject.topic.deserializer,
            'create_time' => Time.now,
            'headers' => {},
            'is_control_record' => false,
            'key' => nil,
            'offset' => 0,
            'partition' => 0,
            'receive_time' => Time.now,
            'topic' => subject.topic.name
          }
        end
      end
    end
  end
end
