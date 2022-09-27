# frozen_string_literal: true

module Karafka
  module Testing
    # Dummy producer client used to buffer messages that we send out in specs
    class DummyProducerClient < ::WaterDrop::Producer::DummyClient
      attr_accessor :messages

      def initialize(rspec)
        super()
        @rspec = rspec
        self.messages = []
      end

      def produce(message)
        self.messages << message
        @rspec._karafka_add_message_to_consumer(message)
        OpenStruct.new
      end

      def reset
        self.messages.clear
      end
    end
  end
end
