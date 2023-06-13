# frozen_string_literal: true

module Karafka
  module Testing
    # Spec producer client used to buffer messages that we send out in specs
    class SpecProducerClient < ::WaterDrop::Clients::Buffered
      # @param rspec [RSpec::Core::ExampleGroup] rspec example we need to hold to trigger actions
      #   on it that are rspec context aware
      def initialize(rspec)
        super(nil)
        @rspec = rspec
      end

      # "Produces" message to Kafka. That is, it acknowledges it locally, adds it to the internal
      # buffer and adds it (if needed) into the current consumer messages buffer
      # @param message [Hash] `Karafka.producer.produce_sync` message hash
      def produce(message)
        @rspec._karafka_add_message_to_consumer_if_needed(message)

        super
      end
    end
  end
end
