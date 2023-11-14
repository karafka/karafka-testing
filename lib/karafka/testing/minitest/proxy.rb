# frozen_string_literal: true

module Karafka
  module Testing
    module MiniTest
      # Proxy object for a nicer `karafka.` API within MiniTest
      # None other should be used by the end users
      class Proxy
        # @param minitest_example [MiniTest::Test] minitest context
        def initialize(minitest_example)
          @minitest_example = minitest_example
        end

        # @param args Anything that the `#_karafka_consumer_for` accepts
        def consumer_for(*args)
          @minitest_example._karafka_consumer_for(*args)
        end

        # @param args Anything that `#_karafka_produce` accepts
        def produce(*args)
          @minitest_example._karafka_produce(*args)
        end

        # @return [Array<Hash>] messages produced via `Karafka#producer`
        def produced_messages
          @minitest_example._karafka_produced_messages
        end
      end
    end
  end
end
