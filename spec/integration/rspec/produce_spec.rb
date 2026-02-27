# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "produce" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  it "delivers a message to the consumer" do
    karafka.produce('{"msg":"hello"}')
    expect(consumer.messages.size).to eq(1)
  end

  it "sets the payload on the delivered message" do
    karafka.produce('{"key":"value"}')
    expect(consumer.messages.first.payload).to eq({ "key" => "value" })
  end

  it "provides raw_payload as original string" do
    karafka.produce('{"key":"value"}')
    expect(consumer.messages.first.raw_payload).to eq('{"key":"value"}')
  end

  it "sets default partition to 0" do
    karafka.produce('{"x":1}')
    expect(consumer.messages.first.partition).to eq(0)
  end

  it "sets default headers to empty hash" do
    karafka.produce('{"x":1}')
    expect(consumer.messages.first.headers).to eq({})
  end

  it "sets default key to nil" do
    karafka.produce('{"x":1}')
    expect(consumer.messages.first.key).to be_nil
  end

  it "sets a timestamp on the message" do
    before = Time.now
    karafka.produce('{"x":1}')
    after = Time.now
    expect(consumer.messages.first.timestamp).to be_between(before, after)
  end

  it "builds a batch of multiple messages on the consumer" do
    karafka.produce('{"n":1}')
    karafka.produce('{"n":2}')
    karafka.produce('{"n":3}')
    expect(consumer.messages.size).to eq(3)
    expect(consumer.messages.map(&:payload)).to eq([{ "n" => 1 }, { "n" => 2 }, { "n" => 3 }])
  end

  context "with metadata" do
    it "passes through the key" do
      karafka.produce('{"x":1}', key: "my_key")
      expect(consumer.messages.first.key).to eq("my_key")
    end

    it "passes through headers" do
      karafka.produce('{"x":1}', headers: { "x-trace" => "abc" })
      expect(consumer.messages.first.headers).to eq({ "x-trace" => "abc" })
    end

    it "passes through partition" do
      karafka.produce('{"x":1}', partition: 5)
      expect(consumer.messages.first.partition).to eq(5)
    end
  end
end
