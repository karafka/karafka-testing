# frozen_string_literal: true

require_relative "../minitest_helper"

class TransactionsTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:other_topic)
    Karafka.producer.stubs(:transactional?).returns(true)
  end

  def test_retains_messages_after_committed_transaction
    Karafka.producer.transaction do
      @karafka.produce('{"txn":"committed"}')
    end

    assert_equal 1, @karafka.produced_messages.size
    assert_equal '{"txn":"committed"}', @karafka.produced_messages.first[:payload]
    assert_equal 1, @consumer.messages.size
  end

  def test_discards_messages_after_aborted_transaction
    Karafka.producer.transaction do
      @karafka.produce('{"txn":"aborted"}')
      raise WaterDrop::Errors::AbortTransaction
    end

    assert_empty @karafka.produced_messages
  end
end
