# frozen_string_literal: true

module Karafka
  module Testing
    module RSpec
      # Proxy object for a nicer `karafka.` API within RSpec
      class Proxy
        # @param rspec_example [RSpec::ExampleGroups] rspec context
        def initialize(rspec_example)
          @rspec_example = rspec_example
        end

        # @param args Anything that the `#karafka_consumer_for` accepts
        def consumer_for(*args)
          @rspec_example.karafka_consumer_for(*args)
        end

        # @param args Anything that the `#karafka_publish` accepts
        def publish(*args)
          @rspec_example.karafka_publish(*args)
        end
      end
    end
  end
end
