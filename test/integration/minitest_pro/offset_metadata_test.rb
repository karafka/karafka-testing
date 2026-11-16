# frozen_string_literal: true

# Runs the Minitest helpers with Karafka Pro. Run as a separate process by
# `test/integration/minitest/offset_metadata_test.rb`, because the other Minitest integration
# tests load Karafka without Pro.

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
