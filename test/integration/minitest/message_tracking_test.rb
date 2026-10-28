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

  def test_includes_key_in_produced_messages
    @karafka.produce('{"x":1}', key: "msg_key")
    msg = @karafka.produced_messages.first

    assert_equal "msg_key", msg[:key]
  end

  def test_tracks_messages_without_a_consumer
    Karafka.producer.produce_sync(topic: "other_topic", payload: '{"standalone":true}')

    assert_equal 1, @karafka.produced_messages.size
    assert_equal '{"standalone":true}', @karafka.produced_messages.first[:payload]
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

  def test_altering_consumer_messages_alters_the_consumer_batch
    @karafka.produce('{"x":1}')
    @karafka.produce('{"x":2}')
    @karafka.consumer_messages.clear

    assert_empty @consumer.messages.to_a

    @karafka.produce('{"x":3}')

    assert_equal([[{ "x" => 3 }, 0]], @consumer.messages.map { |m| [m.payload, m.offset] })
  end
end
