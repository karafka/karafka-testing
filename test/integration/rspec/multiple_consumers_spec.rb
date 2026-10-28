# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "multiple consumers in one example" do
  include Karafka::Testing::RSpec::Helpers

  it "gives each consumer a batch of only its own topic's messages" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)
    consumer2 = karafka.consumer_for(:other_topic)

    karafka.produce('{"x":1}', topic: "test_topic", partition: 3)
    karafka.produce('{"x":2}', topic: "other_topic")
    karafka.produce('{"x":3}', topic: "other_topic")

    expect(consumer1.messages.map { |m| [m.topic, m.partition, m.offset] })
      .to eq([["test_topic", 3, 0]])
    expect(consumer2.messages.map { |m| [m.topic, m.partition, m.offset] })
      .to eq([["other_topic", 0, 0], ["other_topic", 0, 1]])
    expect(consumer2.messages.metadata.first_offset).to eq(0)
    expect(consumer2.messages.metadata.last_offset).to eq(1)
    expect(karafka.consumer_messages.size).to eq(3)
  end

  it "gives each consumer group its own batch when using produce_to" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)
    consumer2 = karafka.consumer_for(:test_topic, :secondary_group)

    karafka.produce_to(consumer1, '{"x":1}')
    karafka.produce_to(consumer2, '{"x":2}')

    expect(consumer1.messages.map(&:payload)).to eq([{ "x" => 1 }])
    expect(consumer2.messages.map(&:payload)).to eq([{ "x" => 2 }])
    expect(consumer2.messages.first.offset).to eq(0)
  end

  it "leaves the consumer without own messages with no batch" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)
    karafka.consumer_for(:other_topic)

    karafka.produce('{"x":1}', topic: "other_topic")

    expect(consumer1.messages).to be_nil
  end

  it "keeps growing each batch on its own when production interleaves" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)
    consumer2 = karafka.consumer_for(:other_topic)

    karafka.produce('{"x":1}', topic: "test_topic")
    karafka.produce('{"x":2}', topic: "other_topic")
    karafka.produce('{"x":3}', topic: "test_topic")

    expect(consumer1.messages.map { |m| [m.payload, m.offset] })
      .to eq([[{ "x" => 1 }, 0], [{ "x" => 3 }, 1]])
    expect(consumer1.messages.metadata.last_offset).to eq(1)
    expect(consumer2.messages.map { |m| [m.payload, m.offset] }).to eq([[{ "x" => 2 }, 0]])
  end

  it "gives a third consumer its own batch and leaves the other two untouched" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)
    consumer2 = karafka.consumer_for(:other_topic)
    consumer3 = karafka.consumer_for(:test_topic, :secondary_group)

    karafka.produce_to(consumer1, '{"x":1}')
    karafka.produce_to(consumer2, '{"x":2}')

    expect(consumer3.messages).to be_nil

    karafka.produce_to(consumer3, '{"x":3}')
    karafka.produce_to(consumer3, '{"x":4}')

    expect(consumer3.messages.map { |m| [m.payload, m.offset] })
      .to eq([[{ "x" => 3 }, 0], [{ "x" => 4 }, 1]])
    expect(consumer1.messages.map { |m| [m.payload, m.offset] }).to eq([[{ "x" => 1 }, 0]])
    expect(consumer2.messages.map { |m| [m.payload, m.offset] }).to eq([[{ "x" => 2 }, 0]])
  end

  it "does not alter the batches when consumer_messages changes after they split" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)
    consumer2 = karafka.consumer_for(:other_topic)

    karafka.produce('{"x":1}', topic: "test_topic")
    karafka.produce('{"x":2}', topic: "other_topic")
    karafka.consumer_messages.clear

    expect(consumer1.messages.map(&:payload)).to eq([{ "x" => 1 }])
    expect(consumer2.messages.map(&:payload)).to eq([{ "x" => 2 }])

    karafka.produce('{"x":3}', topic: "test_topic")

    expect(consumer1.messages.map(&:offset)).to eq([0, 1])
    expect(karafka.consumer_messages.map(&:payload)).to eq([{ "x" => 3 }])
  end

  it "applies an explicit offset only to its message and keeps default offsets per consumer" do
    consumer1 = karafka.consumer_for(:test_topic, :test_group)
    consumer2 = karafka.consumer_for(:other_topic)

    karafka.produce('{"x":1}', topic: "test_topic", offset: 100)
    karafka.produce('{"x":2}', topic: "other_topic")
    karafka.produce('{"x":3}', topic: "test_topic")
    karafka.produce('{"x":4}', topic: "other_topic", offset: 50)

    expect(consumer1.messages.map(&:offset)).to eq([100, 1])
    expect(consumer2.messages.map(&:offset)).to eq([0, 50])
  end
end
