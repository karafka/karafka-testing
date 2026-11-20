# frozen_string_literal: true

# Runs the Minitest helpers with Karafka Pro. Run in its own CI job, because the other Minitest
# integration tests load Karafka without Pro.

require_relative "../pro_helper"
require "minitest/autorun"
require "karafka/testing/minitest/helpers"

class OffsetMetadataTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:offset_metadata_topic)
    2.times { |i| @karafka.produce({ "i" => i }.to_json) }
  end

  def test_reads_no_offset_metadata_by_default
    @consumer.consume

    assert_equal({}, @consumer.restored_state)
  end

  def test_reads_the_set_offset_metadata
    @karafka.offset_metadata = { "count" => 5 }.to_json

    @consumer.consume

    assert_equal({ "count" => 5 }, @consumer.restored_state)
    assert_equal({ "count" => 5 }, @consumer.committed_offset_metadata(cache: false))
  end

  def test_records_marks_with_their_offset_metadata
    @karafka.offset_metadata = { "count" => 5 }.to_json

    @consumer.consume

    assert_equal(
      [
        { topic: "offset_metadata_topic", partition: 0, offset: 0, metadata: '{"first":true}' },
        { topic: "offset_metadata_topic", partition: 0, offset: 1, metadata: '{"count":7}' }
      ],
      @karafka.marks
    )
  end

  def test_reads_false_after_the_partition_was_revoked
    @consumer.coordinator.revoke

    refute @consumer.offset_metadata
  end
end

class TransactionalMarksTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:transactional_marking_topic)
    Karafka.producer.define_singleton_method(:transactional?) { true }
  end

  def teardown
    Karafka.producer.singleton_class.remove_method(:transactional?)
    super
  end

  def test_records_marks_of_a_committed_transaction
    @karafka.produce({ "i" => 0 }.to_json)

    @consumer.consume

    assert_equal(
      [{ topic: "transactional_marking_topic", partition: 0, offset: 0, metadata: "tx-meta" }],
      @karafka.marks
    )
  end

  def test_records_no_marks_of_an_aborted_transaction
    @karafka.produce({ "abort" => true }.to_json)

    @consumer.consume

    assert_empty @karafka.marks
  end
end
