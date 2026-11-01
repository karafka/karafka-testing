# frozen_string_literal: true

require_relative "../minitest_helper"

class ThreadedProduceTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  THREADS = 8

  PER_THREAD = 500

  def setup
    super
    @consumer = @karafka.consumer_for(:other_topic)
  end

  def test_keeps_every_message_with_unique_offsets_when_producing_from_threads
    Array.new(THREADS) do |thread|
      Thread.new { PER_THREAD.times { |i| @karafka.produce("#{thread}-#{i}") } }
    end.each(&:join)

    total = THREADS * PER_THREAD

    assert_equal total, @karafka.produced_messages.size
    assert_equal total, @karafka.consumer_messages.size
    assert_equal (0...total).to_a, @consumer.messages.map(&:offset).sort
  end

  def test_keeps_every_message_when_producing_to_another_topic_from_threads
    Array.new(THREADS) do |thread|
      Thread.new do
        PER_THREAD.times do |i|
          Karafka.producer.produce_sync(topic: "test_topic", payload: "#{thread}-#{i}")
        end
      end
    end.each(&:join)

    assert_equal THREADS * PER_THREAD, @karafka.produced_messages.size
    assert_empty @karafka.consumer_messages
  end
end
