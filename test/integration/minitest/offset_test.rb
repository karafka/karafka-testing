# frozen_string_literal: true

require_relative "../minitest_helper"

class OffsetTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:other_topic)
  end

  def test_auto_increments_offsets_starting_from_zero
    @karafka.produce('{"n":0}')
    @karafka.produce('{"n":1}')
    @karafka.produce('{"n":2}')

    offsets = @consumer.messages.map(&:offset)

    assert_equal [0, 1, 2], offsets
  end

  def test_uses_provided_custom_offset
    @karafka.produce('{"x":1}', offset: 1337)

    assert_equal 1337, @consumer.messages.first.offset
  end

  def test_resumes_auto_increment_after_custom_offset
    @karafka.produce('{"n":0}')
    @karafka.produce('{"n":1}', offset: 100)
    @karafka.produce('{"n":2}')

    offsets = @consumer.messages.map(&:offset)

    assert_equal [0, 100, 2], offsets
  end

  def test_handles_offset_zero_explicitly
    @karafka.produce('{"first":true}', offset: 0)

    assert_equal 0, @consumer.messages.first.offset
  end

  def test_handles_multiple_custom_offsets_in_sequence
    @karafka.produce('{"n":0}', offset: 10)
    @karafka.produce('{"n":1}', offset: 20)
    @karafka.produce('{"n":2}', offset: 30)

    offsets = @consumer.messages.map(&:offset)

    assert_equal [10, 20, 30], offsets
  end
end
