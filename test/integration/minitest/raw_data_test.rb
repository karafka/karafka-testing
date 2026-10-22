# frozen_string_literal: true

require_relative "../minitest_helper"

class RawDataTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:other_topic)
  end

  def test_keeps_raw_payload_as_produced
    @karafka.produce('{"text":"zażółć"}')
    raw_payload = @consumer.messages.first.raw_payload

    assert_equal '{"text":"zażółć"}', raw_payload
    assert_equal Encoding::UTF_8, raw_payload.encoding
  end

  def test_keeps_raw_key_and_header_values_as_produced
    @karafka.produce("{}", key: "kłucz", headers: { "h" => "wartość" })
    message = @consumer.messages.first

    assert_equal "kłucz", message.raw_key
    assert_equal({ "h" => "wartość" }, message.raw_headers)
  end

  def test_assigns_message_to_its_metadata
    @karafka.produce("{}")
    message = @consumer.messages.first

    assert_same message, message.metadata.message
  end

  def test_keeps_nil_raw_payload_of_tombstone
    @karafka.produce(nil, key: "k")

    assert_nil @consumer.messages.first.raw_payload
  end

  def test_keeps_nil_raw_key
    @karafka.produce("{}")

    assert_nil @consumer.messages.first.raw_key
  end

  def test_delivers_empty_headers_when_headers_are_nil
    @karafka.produce("{}", headers: nil)

    assert_equal({}, @consumer.messages.first.raw_headers)
  end
end
