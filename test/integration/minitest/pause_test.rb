# frozen_string_literal: true

require_relative "../minitest_helper"

class PauseTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:pausing_topic)
  end

  def test_pauses_without_raising
    3.times { |i| @karafka.produce({ "i" => i }.to_json) }

    @consumer.consume

    assert_predicate @consumer.coordinator.pause_tracker, :paused?
  end

  def test_does_not_pause_when_not_asked_to
    @karafka.produce({ "i" => 0 }.to_json)

    @consumer.consume

    refute_predicate @consumer.coordinator.pause_tracker, :paused?
  end

  def test_resumes_after_a_pause
    3.times { @karafka.produce({ "resume" => true }.to_json) }

    @consumer.consume

    assert_predicate @consumer.coordinator.pause_tracker, :expired?
  end

  def test_records_pauses
    3.times { |i| @karafka.produce({ "i" => i }.to_json) }

    @consumer.consume

    assert_equal(
      [{ topic: "pausing_topic", partition: 0, offset: 2, timeout: 5_000 }],
      @karafka.pauses
    )
    assert_empty @karafka.resumes
  end

  def test_records_resumes_of_paused_consumers
    3.times { @karafka.produce({ "resume" => true }.to_json) }

    @consumer.consume

    assert_equal [{ topic: "pausing_topic", partition: 0 }], @karafka.resumes
  end

  def test_does_not_record_resumes_without_a_pause
    @karafka.produce({ "resume" => true }.to_json)

    @consumer.consume

    assert_empty @karafka.pauses
    assert_empty @karafka.resumes
  end

  def test_records_one_resume_per_pause
    3.times { @karafka.produce({ "resume_twice" => true }.to_json) }

    @consumer.consume

    assert_equal [{ topic: "pausing_topic", partition: 0 }], @karafka.resumes
    refute_predicate @consumer.coordinator.pause_tracker, :paused?
  end
end
