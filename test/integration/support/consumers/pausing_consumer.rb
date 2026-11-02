# frozen_string_literal: true

class PausingConsumer < Karafka::BaseConsumer
  def consume
    pause(messages.last.offset, 5_000) if messages.size > 2
    resume if messages.first.payload["resume"]
    2.times { resume } if messages.first.payload["resume_twice"]
  end
end
