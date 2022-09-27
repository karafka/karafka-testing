# frozen_string_literal: true

module Karafka
  module Testing
    # Spec producer client used to buffer messages that we send out in specs
    class SpecProducerClient < ::WaterDrop::Producer::DummyClient
      attr_accessor :messages

      # Sync fake response for the message delivery to Kafka, since we do not dispatch anything
      class SyncResponse
        # @param _args Handler wait arguments (irrelevant as waiting is fake here)
        def wait(*_args)
          false
        end
      end

      # @param rspec [RSpec::Core::ExampleGroup] rspec example we need to hold to trigger actions
      #   on it that are rspec context aware
      def initialize(rspec)
        super()
        @rspec = rspec
        self.messages = []
      end

      # "Produces" message to Kafka. That is, it acknowledges it locally, adds it to the internal
      # buffer and adds it (if needed) into the current consumer messages buffer
      # @param message [Hash] `Karafka.producer.produce_sync` message hash
      def produce(message)
        messages << message

        @rspec._karafka_add_message_to_consumer_if_needed(message)

        SyncResponse.new
      end

      # Clears internal buffer
      # Used in between specs so messages do not leak out
      def reset
        messages.clear
      end
    end
  end
end
