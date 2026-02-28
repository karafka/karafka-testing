# frozen_string_literal: true

require_relative "../minitest_helper"

class ProduceToTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def test_delivers_only_to_targeted_consumer
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)
    consumer2 = @karafka.consumer_for(:test_topic, :secondary_group)

    @karafka.produce_to(consumer1, '{"event":"click"}')

    assert_equal 1, consumer1.messages.size
    assert_equal({ "event" => "click" }, consumer1.messages.first.payload)
    assert_nil consumer2.messages
  end

  def test_delivers_with_metadata
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)

    @karafka.produce_to(consumer1, '{"x":1}', key: "k1", headers: { "h" => "v" })

    assert_equal "k1", consumer1.messages.first.key
    assert_equal({ "h" => "v" }, consumer1.messages.first.headers)
  end

  def test_consumer_processes_batch_via_consume
    test_consumer = @karafka.consumer_for(:test_topic, :test_group)
    @karafka.produce_to(test_consumer, '{"key":"value"}')
    test_consumer.consume
    assert_equal [{ "key" => "value" }], test_consumer.consumed_payloads
  end
end
