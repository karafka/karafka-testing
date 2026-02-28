# frozen_string_literal: true

require_relative "../minitest_helper"

class MessageIsolationTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  # Minitest does not guarantee test order by default but these tests verify
  # that each test starts with a clean state regardless of execution order.

  def test_first_example_starts_clean
    @consumer = @karafka.consumer_for(:other_topic)
    assert_empty @karafka.produced_messages
    assert_empty @karafka.consumer_messages
    @karafka.produce('{"leak":"test"}')
  end

  def test_second_example_starts_clean
    @consumer = @karafka.consumer_for(:other_topic)
    assert_empty @karafka.produced_messages
    assert_empty @karafka.consumer_messages
  end
end
