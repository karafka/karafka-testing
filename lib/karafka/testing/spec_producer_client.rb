# frozen_string_literal: true

module Karafka
  module Testing
    # Spec producer client used to buffer messages that we send out in specs
    #
    # @note Code under test may produce from many threads at once, so every operation that touches
    #   the buffers runs under one lock
    class SpecProducerClient < ::WaterDrop::Clients::Buffered
      # @param example [RSpec::Core::ExampleGroup, Minitest::Test] test example we need to hold to
      #   trigger actions on it that are test context aware
      def initialize(example)
        super(nil)
        @example = example
        @mutex = Mutex.new
      end

      # "Produces" message to Kafka. That is, it acknowledges it locally, adds it to the internal
      # buffer and adds it (if needed) into the current consumer messages buffer
      # @param message [Hash] `Karafka.producer.produce_sync` message hash
      def produce(message)
        @mutex.synchronize do
          @example._karafka_add_message_to_consumer_if_needed(message)

          super
        end
      end

      # Starts the transaction on a given level
      def begin_transaction
        @mutex.synchronize { super }
      end

      # Finishes given level of transaction
      def commit_transaction
        @mutex.synchronize { super }
      end

      # Aborts the transaction
      def abort_transaction
        @mutex.synchronize { super }
      end

      # Clears internal buffer. Used in between specs so messages do not leak out
      def reset
        @mutex.synchronize { super }
      end
    end
  end
end
