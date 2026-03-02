# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "produce_to" do
  include Karafka::Testing::RSpec::Helpers

  it "delivers only to the targeted consumer" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)
    consumer2 = karafka.consumer_for(:test_topic, :secondary_group)

    karafka.produce_to(consumer1, '{"event":"click"}')

    expect(consumer1.messages.size).to eq(1)
    expect(consumer1.messages.first.payload).to eq({ "event" => "click" })
    expect(consumer2.messages).to be_nil
  end

  it "delivers with metadata (key and headers)" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)

    karafka.produce_to(consumer1, '{"x":1}', key: "k1", headers: { "h" => "v" })

    expect(consumer1.messages.first.key).to eq("k1")
    expect(consumer1.messages.first.headers).to eq({ "h" => "v" })
  end

  it "allows the consumer to process the batch via #consume" do
    test_consumer = karafka.consumer_for(:test_topic, :test_group)
    karafka.produce_to(test_consumer, '{"key":"value"}')
    test_consumer.consume
    expect(test_consumer.consumed_payloads).to eq([{ "key" => "value" }])
  end
end
