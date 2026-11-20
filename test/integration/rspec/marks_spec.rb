# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "marking as consumed" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:marking_topic) }

  it "records marks" do
    2.times { |i| karafka.produce({ "i" => i }.to_json) }

    consumer.consume

    expect(karafka.marks).to eq(
      [
        { topic: "marking_topic", partition: 0, offset: 0, metadata: nil },
        { topic: "marking_topic", partition: 0, offset: 1, metadata: nil }
      ]
    )
  end

  it "records sync marks" do
    karafka.produce({ "sync" => true }.to_json, partition: 2)

    consumer.consume

    expect(karafka.marks).to eq([{ topic: "marking_topic", partition: 2, offset: 0, metadata: nil }])
  end

  it "records nothing without consumption" do
    karafka.produce({ "i" => 0 }.to_json)

    expect(karafka.marks).to be_empty
  end
end
