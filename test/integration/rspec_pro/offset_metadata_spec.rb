# frozen_string_literal: true

# Runs the RSpec helpers with Karafka Pro. Run as a separate process by
# `test/integration/rspec/offset_metadata_spec.rb`, because the other RSpec integration specs
# load Karafka without Pro.

require_relative "../pro_helper"
require "karafka/testing/rspec/helpers"

RSpec.describe OffsetMetadataConsumer do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:offset_metadata_topic) }

  before { 2.times { |i| karafka.produce({ "i" => i }.to_json) } }

  it "reads no offset metadata by default" do
    consumer.consume

    expect(consumer.restored_state).to eq({})
  end

  it "reads the set offset metadata" do
    karafka.offset_metadata = { "count" => 5 }.to_json

    consumer.consume

    expect(consumer.restored_state).to eq({ "count" => 5 })
    expect(consumer.committed_offset_metadata(cache: false)).to eq({ "count" => 5 })
  end

  it "records marks with their offset metadata" do
    karafka.offset_metadata = { "count" => 5 }.to_json

    consumer.consume

    expect(karafka.marks).to eq(
      [
        { topic: "offset_metadata_topic", partition: 0, offset: 0, metadata: '{"first":true}' },
        { topic: "offset_metadata_topic", partition: 0, offset: 1, metadata: '{"count":7}' }
      ]
    )
  end

  it "reads false after the partition was revoked" do
    consumer.coordinator.revoke

    expect(consumer.offset_metadata).to be(false)
  end
end
