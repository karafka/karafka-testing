# frozen_string_literal: true

require_relative "../minitest_helper"

class MarksTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:marking_topic)
  end

  def test_records_marks
    2.times { |i| @karafka.produce({ "i" => i }.to_json) }

    @consumer.consume

    assert_equal(
      [
        { topic: "marking_topic", partition: 0, offset: 0, metadata: nil },
        { topic: "marking_topic", partition: 0, offset: 1, metadata: nil }
      ],
      @karafka.marks
    )
  end

  def test_records_sync_marks
    @karafka.produce({ "sync" => true }.to_json, partition: 2)

    @consumer.consume

    assert_equal(
      [{ topic: "marking_topic", partition: 2, offset: 0, metadata: nil }],
      @karafka.marks
    )
  end

  def test_records_nothing_without_consumption
    @karafka.produce({ "i" => 0 }.to_json)

    assert_empty @karafka.marks
  end
end
