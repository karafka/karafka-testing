# frozen_string_literal: true

module Karafka
  module Testing
    # A spec client that takes over client delegated methods from the consumers
    # For specs we do not mark anything as consumed, nor do we really send heartbeats.
    # Those things are tested in the framework itself
    class SpecConsumerClient
      %i[
        mark_as_consumed
        mark_as_consumed!
      ].each do |caught_delegator|
        define_method(caught_delegator) { |*| }
      end

      # @return [Boolean] assignments are never lost for specs
      def assignment_lost?
        false
      end
    end
  end
end
