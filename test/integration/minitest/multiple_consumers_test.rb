# frozen_string_literal: true

require_relative "../minitest_helper"

class MultipleConsumersTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def test_gives_each_consumer_a_batch_of_only_its_own_topic_messages
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)
    consumer2 = @karafka.consumer_for(:other_topic)

    @karafka.produce_to(consumer1, '{"x":1}', partition: 3)
    @karafka.produce_to(consumer2, '{"x":2}')
    @karafka.produce_to(consumer2, '{"x":3}')

    assert_equal(
      [["test_topic", 3, 0]],
      consumer1.messages.map { |m| [m.topic, m.partition, m.offset] }
    )
    assert_equal(
      [["other_topic", 0, 0], ["other_topic", 0, 1]],
      consumer2.messages.map { |m| [m.topic, m.partition, m.offset] }
    )
    assert_equal(
      [0, 1, 3],
      [
        consumer2.messages.metadata.first_offset,
        consumer2.messages.metadata.last_offset,
        @karafka.consumer_messages.size
      ]
    )
  end

  def test_gives_each_consumer_group_its_own_batch
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)
    consumer2 = @karafka.consumer_for(:test_topic, :secondary_group)

    @karafka.produce_to(consumer1, '{"x":1}')
    @karafka.produce_to(consumer2, '{"x":2}')

    assert_equal [{ "x" => 1 }], consumer1.messages.map(&:payload)
    assert_equal [{ "x" => 2 }], consumer2.messages.map(&:payload)
    assert_equal 0, consumer2.messages.first.offset
  end
end
