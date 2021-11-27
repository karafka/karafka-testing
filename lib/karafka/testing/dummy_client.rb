# frozen_string_literal: true

module Karafka
  module Testing
    # A dummy client that takes over client delegated methods from the consumers
    # For specs we do not mark anything as consumed, nor do we really send heartbeats.
    # Those things are tested in the framework itself
    class DummyClient
      %i[
        mark_as_consumed
        mark_as_consumed!
        trigger_heartbeat
        trigger_heartbeat!
      ].each do |caught_delegator|
        define_method(caught_delegator) { |*| }
      end
    end
  end
end
