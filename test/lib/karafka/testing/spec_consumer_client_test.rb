# frozen_string_literal: true

require "test_helper"

class KarafkaTestingSpecConsumerClientTest < Minitest::Test
  def setup
    @client = Karafka::Testing::SpecConsumerClient.new
  end

  def test_mark_as_consumed_returns_true
    assert_same true, @client.mark_as_consumed
  end

  def test_mark_as_consumed_accepts_any_arguments
    assert_same true, @client.mark_as_consumed("arg1", "arg2")
  end

  def test_mark_as_consumed_bang_returns_true
    assert_same true, @client.mark_as_consumed!
  end

  def test_mark_as_consumed_bang_accepts_any_arguments
    assert_same true, @client.mark_as_consumed!("arg1")
  end

  def test_commit_offsets_returns_true
    assert_same true, @client.commit_offsets
  end

  def test_commit_offsets_accepts_any_arguments
    assert_same true, @client.commit_offsets("arg1")
  end

  def test_commit_offsets_bang_returns_true
    assert_same true, @client.commit_offsets!
  end

  def test_commit_offsets_bang_accepts_any_arguments
    assert_same true, @client.commit_offsets!("arg1", "arg2")
  end

  def test_seek_returns_true
    assert_same true, @client.seek
  end

  def test_seek_accepts_any_arguments
    assert_same true, @client.seek("topic", 0, 100)
  end

  def test_consumer_group_metadata_pointer_returns_true
    assert_same true, @client.consumer_group_metadata_pointer
  end

  def test_assignment_lost_returns_false
    assert_same false, @client.assignment_lost?
  end
end
