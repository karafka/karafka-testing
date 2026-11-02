# frozen_string_literal: true

module Karafka
  module Testing
    # Resumes the partition on the client when a paused consumer resumes. In a real run the
    # listener does it before the next poll, which never happens in specs.
    module SpecConsumerResume
      # Expires the pause and resumes the partition on the client if it was paused
      def resume
        paused = coordinator.pause_tracker.paused?

        super

        client.resume(topic.name, partition) if paused
      end
    end
  end
end
