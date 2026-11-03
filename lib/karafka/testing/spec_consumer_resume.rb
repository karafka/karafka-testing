# frozen_string_literal: true

module Karafka
  module Testing
    # Resumes the partition on the client when a paused consumer resumes. In a real run the
    # listener does it before the next poll, which never happens in specs.
    module SpecConsumerResume
      # Expires the pause and, if it was paused, resumes the partition as the listener does
      def resume
        pause_tracker = coordinator.pause_tracker
        paused = pause_tracker.paused?

        super

        return unless paused

        pause_tracker.resume
        client.resume(topic.name, partition)
      end
    end
  end
end
