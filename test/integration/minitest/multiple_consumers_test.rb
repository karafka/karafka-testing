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

  def test_leaves_the_consumer_without_own_messages_with_no_batch
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)
    consumer2 = @karafka.consumer_for(:other_topic)

    @karafka.produce_to(consumer2, '{"x":1}')

    assert_nil consumer1.messages
  end

  def test_keeps_growing_each_batch_on_its_own_when_production_interleaves
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)
    consumer2 = @karafka.consumer_for(:other_topic)

    @karafka.produce_to(consumer1, '{"x":1}')
    @karafka.produce_to(consumer2, '{"x":2}')
    @karafka.produce_to(consumer1, '{"x":3}')

    assert_equal(
      [[{ "x" => 1 }, 0], [{ "x" => 3 }, 1]],
      consumer1.messages.map { |m| [m.payload, m.offset] }
    )
    assert_equal 1, consumer1.messages.metadata.last_offset
    assert_equal([[{ "x" => 2 }, 0]], consumer2.messages.map { |m| [m.payload, m.offset] })
  end

  def test_gives_a_third_consumer_its_own_batch_and_leaves_the_other_two_untouched
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)
    consumer2 = @karafka.consumer_for(:other_topic)
    consumer3 = @karafka.consumer_for(:test_topic, :secondary_group)

    @karafka.produce_to(consumer1, '{"x":1}')
    @karafka.produce_to(consumer2, '{"x":2}')

    assert_nil consumer3.messages

    @karafka.produce_to(consumer3, '{"x":3}')
    @karafka.produce_to(consumer3, '{"x":4}')

    assert_equal(
      [[{ "x" => 3 }, 0], [{ "x" => 4 }, 1]],
      consumer3.messages.map { |m| [m.payload, m.offset] }
    )
    assert_equal(
      [[[{ "x" => 1 }, 0]], [[{ "x" => 2 }, 0]]],
      [consumer1, consumer2].map { |c| c.messages.map { |m| [m.payload, m.offset] } }
    )
  end

  def test_does_not_alter_the_batches_when_consumer_messages_changes_after_they_split
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)
    consumer2 = @karafka.consumer_for(:other_topic)

    @karafka.produce_to(consumer1, '{"x":1}')
    @karafka.produce_to(consumer2, '{"x":2}')
    @karafka.consumer_messages.clear

    assert_equal(
      [[{ "x" => 1 }], [{ "x" => 2 }]],
      [consumer1, consumer2].map { |c| c.messages.map(&:payload) }
    )

    @karafka.produce_to(consumer1, '{"x":3}')

    assert_equal [0, 1], consumer1.messages.map(&:offset)
    assert_equal [{ "x" => 3 }], @karafka.consumer_messages.map(&:payload)
  end

  def test_applies_an_explicit_offset_only_to_its_message_and_keeps_default_offsets_per_consumer
    consumer1 = @karafka.consumer_for(:test_topic, :test_group)
    consumer2 = @karafka.consumer_for(:other_topic)

    @karafka.produce_to(consumer1, '{"x":1}', offset: 100)
    @karafka.produce_to(consumer2, '{"x":2}')
    @karafka.produce_to(consumer1, '{"x":3}')
    @karafka.produce_to(consumer2, '{"x":4}', offset: 50)

    assert_equal [100, 1], consumer1.messages.map(&:offset)
    assert_equal [0, 50], consumer2.messages.map(&:offset)
  end
end
