# frozen_string_literal: true

class MarkingConsumer < Karafka::BaseConsumer
  def consume
    messages.each do |message|
      message.payload["sync"] ? mark_as_consumed!(message) : mark_as_consumed(message)
    end
  end
end
