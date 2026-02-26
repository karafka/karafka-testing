# frozen_string_literal: true

require_relative "integration_spec_helper"

RSpec.describe "Karafka::Testing::RSpec::Helpers integration" do
  include Karafka::Testing::RSpec::Helpers

  describe "#consumer_for" do
    it "returns an instance of the configured consumer class" do
      consumer = karafka.consumer_for(:test_topic, :test_group)
      expect(consumer).to be_a(TestConsumer)
    end

    it "assigns the correct topic to the consumer" do
      consumer = karafka.consumer_for(:test_topic, :test_group)
      expect(consumer.topic.name).to eq("test_topic")
    end

    it "provides a mock client on the consumer" do
      consumer = karafka.consumer_for(:test_topic, :test_group)
      expect(consumer.client).to be_a(Karafka::Testing::SpecConsumerClient)
    end

    it "raises TopicNotFoundError for a non-existent topic" do
      expect { karafka.consumer_for(:nonexistent_topic) }
        .to raise_error(Karafka::Testing::Errors::TopicNotFoundError)
    end

    it "raises TopicInManyConsumerGroupsError without group disambiguation" do
      expect { karafka.consumer_for(:test_topic) }
        .to raise_error(Karafka::Testing::Errors::TopicInManyConsumerGroupsError)
    end

    it "works with consumer group disambiguation" do
      consumer = karafka.consumer_for(:test_topic, :secondary_group)
      expect(consumer).to be_a(OtherConsumer)
      expect(consumer.topic.name).to eq("test_topic")
    end

    it "returns TestConsumer for test_topic in the default group" do
      consumer = karafka.consumer_for(:test_topic, :test_group)
      expect(consumer).to be_a(TestConsumer)
    end
  end

  describe "#produce basics" do
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

    it "auto-increments offsets starting from 0" do
      karafka.produce('{"n":0}')
      karafka.produce('{"n":1}')
      karafka.produce('{"n":2}')

      offsets = consumer.messages.map(&:offset)
      expect(offsets).to eq([0, 1, 2])
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
  end

  describe "#produce with custom offset" do
    subject(:consumer) { karafka.consumer_for(:other_topic) }

    it "uses the provided offset" do
      karafka.produce('{"x":1}', offset: 1337)
      expect(consumer.messages.first.offset).to eq(1337)
    end

    it "resumes auto-increment after a custom offset" do
      karafka.produce('{"n":0}')
      karafka.produce('{"n":1}', offset: 100)
      karafka.produce('{"n":2}')

      offsets = consumer.messages.map(&:offset)
      expect(offsets).to eq([0, 100, 2])
    end
  end

  describe "#produce with metadata" do
    subject(:consumer) { karafka.consumer_for(:other_topic) }

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

  describe "#produced_messages" do
    subject(:consumer) { karafka.consumer_for(:other_topic) }

    it "tracks all produced messages" do
      karafka.produce('{"n":1}')
      karafka.produce('{"n":2}')
      expect(karafka.produced_messages.size).to eq(2)
    end

    it "includes topic and payload in produced messages" do
      karafka.produce('{"data":"test"}')
      msg = karafka.produced_messages.first
      expect(msg[:topic]).to eq("other_topic")
      expect(msg[:payload]).to eq('{"data":"test"}')
    end
  end

  describe "#consumer_messages" do
    subject(:consumer) { karafka.consumer_for(:other_topic) }

    it "returns the internal message buffer" do
      karafka.produce('{"n":1}')
      karafka.produce('{"n":2}')
      expect(karafka.consumer_messages.size).to eq(2)
    end

    it "contains Karafka::Messages::Message objects" do
      karafka.produce('{"x":1}')
      expect(karafka.consumer_messages.first).to be_a(Karafka::Messages::Message)
    end
  end

  describe "#produce_to" do
    it "delivers only to the targeted consumer" do
      consumer1 = karafka.consumer_for(:test_topic, :test_group)
      consumer2 = karafka.consumer_for(:test_topic, :secondary_group)

      karafka.produce_to(consumer1, '{"event":"click"}')

      expect(consumer1.messages.size).to eq(1)
      expect(consumer1.messages.first.payload).to eq({ "event" => "click" })
      expect(consumer2.messages).to be_nil
    end
  end

  describe "consumer #consume" do
    it "allows the consumer to process the batch via #consume" do
      test_consumer = karafka.consumer_for(:test_topic, :test_group)
      karafka.produce_to(test_consumer, '{"key":"value"}')
      test_consumer.consume
      expect(test_consumer.consumed_payloads).to eq([{ "key" => "value" }])
    end
  end

  describe "message isolation between examples" do
    subject(:consumer) { karafka.consumer_for(:other_topic) }

    it "starts with no messages (first example)" do
      expect(karafka.produced_messages).to be_empty
      expect(karafka.consumer_messages).to be_empty
      karafka.produce('{"leak":"test"}')
    end

    it "starts with no messages (second example)" do
      expect(karafka.produced_messages).to be_empty
      expect(karafka.consumer_messages).to be_empty
    end
  end
end
