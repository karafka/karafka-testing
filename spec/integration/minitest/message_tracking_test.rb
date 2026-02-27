# frozen_string_literal: true

require_relative "../minitest_helper"

class MessageTrackingTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:other_topic)
  end

  def test_tracks_all_produced_messages
    @karafka.produce('{"n":1}')
    @karafka.produce('{"n":2}')
    assert_equal 2, @karafka.produced_messages.size
  end

  def test_includes_topic_and_payload_in_produced_messages
    @karafka.produce('{"data":"test"}')
    msg = @karafka.produced_messages.first
    assert_equal "other_topic", msg[:topic]
    assert_equal '{"data":"test"}', msg[:payload]
  end

  def test_returns_internal_message_buffer
    @karafka.produce('{"n":1}')
    @karafka.produce('{"n":2}')
    assert_equal 2, @karafka.consumer_messages.size
  end

  def test_contains_karafka_message_objects
    @karafka.produce('{"x":1}')
    assert_kind_of Karafka::Messages::Message, @karafka.consumer_messages.first
  end
end
