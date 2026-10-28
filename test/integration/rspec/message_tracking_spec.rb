# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "message tracking" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  describe "produced_messages" do
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

    it "includes key in produced messages" do
      karafka.produce('{"x":1}', key: "msg_key")
      msg = karafka.produced_messages.first
      expect(msg[:key]).to eq("msg_key")
    end
  end

  describe "producer-only testing" do
    it "tracks messages without a consumer" do
      Karafka.producer.produce_sync(topic: "other_topic", payload: '{"standalone":true}')
      expect(karafka.produced_messages.size).to eq(1)
      expect(karafka.produced_messages.first[:payload]).to eq('{"standalone":true}')
    end
  end

  describe "consumer_messages" do
    it "returns the internal message buffer" do
      karafka.produce('{"n":1}')
      karafka.produce('{"n":2}')
      expect(karafka.consumer_messages.size).to eq(2)
    end

    it "contains Karafka::Messages::Message objects" do
      karafka.produce('{"x":1}')
      expect(karafka.consumer_messages.first).to be_a(Karafka::Messages::Message)
    end

    it "alters the consumer batch when changed" do
      karafka.produce('{"x":1}')
      karafka.produce('{"x":2}')
      karafka.consumer_messages.clear

      expect(consumer.messages.to_a).to be_empty

      karafka.produce('{"x":3}')

      expect(consumer.messages.map { |m| [m.payload, m.offset] }).to eq([[{ "x" => 3 }, 0]])
    end
  end
end
