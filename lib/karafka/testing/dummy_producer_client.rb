# frozen_string_literal: true

module Karafka
  module Testing
    class DummyProducerClient < ::WaterDrop::Producer::DummyClient
      attr_accessor :produced_messages

      def produce(message)
        self.produced_messages ||= []
        self.produced_messages << message
      end

      def reset
        self.produced_messages = []
      end
    end
  end
end
