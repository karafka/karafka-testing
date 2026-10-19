# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "raw data" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  let(:message) { consumer.messages.last }

  context "when the message has a payload, a key and headers" do
    before do
      karafka.produce('{"text":"zażółć"}', key: "kłucz", headers: { "h" => "wartość" })
    end

    it "keeps the raw payload as produced" do
      expect(message.raw_payload).to eq('{"text":"zażółć"}')
      expect(message.raw_payload.encoding).to eq(Encoding::UTF_8)
    end

    it "keeps the raw key and header values as produced" do
      expect(message.raw_key).to eq("kłucz")
      expect(message.raw_headers).to eq({ "h" => "wartość" })
    end

    it "assigns the message to its metadata" do
      expect(message.metadata.message).to be(message)
    end
  end

  context "when the message is a tombstone" do
    before { karafka.produce(nil, key: "k") }

    it "keeps the nil raw payload" do
      expect(message.raw_payload).to be_nil
    end
  end

  context "when there is no key" do
    before { karafka.produce("{}") }

    it "keeps the nil raw key" do
      expect(message.raw_key).to be_nil
    end
  end

  context "when headers are nil" do
    before { karafka.produce("{}", headers: nil) }

    it "delivers empty headers" do
      expect(message.raw_headers).to eq({})
    end
  end
end
