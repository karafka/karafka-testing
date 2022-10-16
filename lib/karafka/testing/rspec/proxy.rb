# frozen_string_literal: true

module Karafka
  module Testing
    module RSpec
      # Proxy object for a nicer `karafka.` API within RSpec
      # None other should be used by the end users
      class Proxy
        # @param rspec_example [RSpec::ExampleGroups] rspec context
        def initialize(rspec_example)
          @rspec_example = rspec_example
        end

        # @param args Anything that the `#_karafka_consumer_for` accepts
        def consumer_for(*args)
          @rspec_example._karafka_consumer_for(*args)
        end

        # @param args Anything that `#_karafka_produce` accepts
        def produce(*args)
          @rspec_example._karafka_produce(*args)
        end

        # @return [Array<Hash>] messages produced via `Karafka#producer`
        def produced_messages
          @rspec_example._karafka_produced_messages
        end
      end
    end
  end
end
