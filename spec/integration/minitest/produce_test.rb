# frozen_string_literal: true

require_relative "../minitest_helper"

class ProduceTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:other_topic)
  end

  def test_delivers_message_to_consumer
    @karafka.produce('{"msg":"hello"}')

    assert_equal 1, @consumer.messages.size
  end

  def test_sets_payload_on_delivered_message
    @karafka.produce('{"key":"value"}')

    assert_equal({ "key" => "value" }, @consumer.messages.first.payload)
  end

  def test_provides_raw_payload_as_original_string
    @karafka.produce('{"key":"value"}')

    assert_equal '{"key":"value"}', @consumer.messages.first.raw_payload
  end

  def test_sets_default_partition_to_zero
    @karafka.produce('{"x":1}')

    assert_equal 0, @consumer.messages.first.partition
  end

  def test_sets_default_headers_to_empty_hash
    @karafka.produce('{"x":1}')

    assert_equal({}, @consumer.messages.first.headers)
  end

  def test_sets_default_key_to_nil
    @karafka.produce('{"x":1}')

    assert_nil @consumer.messages.first.key
  end

  def test_sets_timestamp_on_message
    before = Time.now
    @karafka.produce('{"x":1}')
    after = Time.now
    timestamp = @consumer.messages.first.timestamp

    assert timestamp.between?(before, after)
  end

  def test_builds_batch_of_multiple_messages
    @karafka.produce('{"n":1}')
    @karafka.produce('{"n":2}')
    @karafka.produce('{"n":3}')

    assert_equal 3, @consumer.messages.size
    assert_equal [{ "n" => 1 }, { "n" => 2 }, { "n" => 3 }], @consumer.messages.map(&:payload)
  end

  def test_passes_through_key
    @karafka.produce('{"x":1}', key: "my_key")

    assert_equal "my_key", @consumer.messages.first.key
  end

  def test_passes_through_headers
    @karafka.produce('{"x":1}', headers: { "x-trace" => "abc" })

    assert_equal({ "x-trace" => "abc" }, @consumer.messages.first.headers)
  end

  def test_passes_through_partition
    @karafka.produce('{"x":1}', partition: 5)

    assert_equal 5, @consumer.messages.first.partition
  end
end
