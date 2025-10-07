# frozen_string_literal: true

module Karafka
  module Testing
    module Minitest
      # Proxy object for a nicer `karafka.` API within Minitest
      # None other should be used by the end users
      class Proxy
        # @param minitest_example [Minitest::Test] minitest context
        def initialize(minitest_example)
          @minitest_example = minitest_example
        end

        # Forwards all arguments to `#_karafka_consumer_for`
        def consumer_for(*)
          @minitest_example._karafka_consumer_for(*)
        end

        # Forwards all arguments to `#_karafka_produce`
        def produce(*)
          @minitest_example._karafka_produce(*)
        end

        # @return [Array<Hash>] messages produced via `Karafka#producer`
        def produced_messages
          @minitest_example._karafka_produced_messages
        end

        # @return [Array<Karafka::Messages::Message>] array of messages that will be used to
        #   construct the final consumer messages batch
        def consumer_messages
          @minitest_example._karafka_consumer_messages
        end
      end
    end
  end
end
