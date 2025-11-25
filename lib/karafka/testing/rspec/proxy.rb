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

        # Forwards all arguments to `#_karafka_consumer_for`
        def consumer_for(*)
          @rspec_example._karafka_consumer_for(*)
        end

        # Forwards all arguments to `#_karafka_produce`
        def produce(*)
          @rspec_example._karafka_produce(*)
        end

        # Forwards all arguments to `#_karafka_produce_to`
        def produce_to(*)
          @rspec_example._karafka_produce_to(*)
        end

        # @return [Array<Hash>] messages produced via `Karafka#producer`
        def produced_messages
          @rspec_example._karafka_produced_messages
        end

        # @return [Array<Karafka::Messages::Message>] array of messages that will be used to
        #   construct the final consumer messages batch
        def consumer_messages
          @rspec_example._karafka_consumer_messages
        end
      end
    end
  end
end
