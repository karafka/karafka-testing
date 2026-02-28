# frozen_string_literal: true

class TestConsumer < Karafka::BaseConsumer
  attr_reader :consumed_payloads

  def initialize
    super
    @consumed_payloads = []
  end

  def consume
    messages.each do |message|
      @consumed_payloads << message.payload
    end
  end
end
