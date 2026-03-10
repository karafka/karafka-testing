# frozen_string_literal: true

require_relative "../rspec_helper"

# When described_class is a Karafka consumer, implicit (unnamed) subject should work
# as a fallback for consumer resolution without needing subject(:consumer) or let(:consumer)
RSpec.describe OtherConsumer do
  include Karafka::Testing::RSpec::Helpers

  subject { karafka.consumer_for(:other_topic) }

  it "delivers a message to the implicit subject" do
    karafka.produce('{"msg":"hello"}')
    expect(subject.messages.size).to eq(1)
  end

  it "sets the payload on the delivered message" do
    karafka.produce('{"key":"value"}')
    expect(subject.messages.first.payload).to eq({ "key" => "value" })
  end

  it "builds a batch of multiple messages" do
    karafka.produce('{"n":1}')
    karafka.produce('{"n":2}')
    expect(subject.messages.size).to eq(2)
    expect(subject.messages.map(&:payload)).to eq([{ "n" => 1 }, { "n" => 2 }])
  end

  it "allows calling consume on the subject" do
    karafka.produce('{"key":"value"}')
    expect { subject.consume }.not_to raise_error
  end

  context "with metadata" do
    it "passes through the key" do
      karafka.produce('{"x":1}', key: "my_key")
      expect(subject.messages.first.key).to eq("my_key")
    end

    it "passes through headers" do
      karafka.produce('{"x":1}', headers: { "x-trace" => "abc" })
      expect(subject.messages.first.headers).to eq({ "x-trace" => "abc" })
    end
  end
end

# When described_class is a consumer, named subject(:consumer) still works as before
RSpec.describe OtherConsumer do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  it "still works with named subject" do
    karafka.produce('{"msg":"hello"}')
    expect(consumer.messages.size).to eq(1)
  end
end

# Guard: described_class is a consumer but default subject (unconfigured described_class.new)
# should fall back to consumer mappings without raising
RSpec.describe OtherConsumer, "with default subject" do
  include Karafka::Testing::RSpec::Helpers

  # No custom subject — default RSpec subject would be OtherConsumer.new (unconfigured)

  it "falls back to mappings when default subject has no coordinator" do
    consumer = karafka.consumer_for(:other_topic)
    karafka.produce('{"x":1}', topic: "other_topic")
    expect(consumer.messages.size).to eq(1)
  end

  it "does not raise when producing without explicit topic" do
    karafka.consumer_for(:other_topic)
    expect { karafka.produce('{"x":1}') }.not_to raise_error
  end
end

# Guard: described_class is a consumer but subject is overridden to a non-consumer object
RSpec.describe OtherConsumer, "with non-consumer subject" do
  include Karafka::Testing::RSpec::Helpers

  subject { "not a consumer" }

  it "falls back to mappings when subject is not a BaseConsumer" do
    consumer = karafka.consumer_for(:other_topic)
    karafka.produce('{"x":1}', topic: "other_topic")
    expect(consumer.messages.size).to eq(1)
  end
end

# Guard: described_class is a consumer, subject is configured, but produce targets a different
# topic — message should not be routed to subject
RSpec.describe OtherConsumer, "with mismatched topic" do
  include Karafka::Testing::RSpec::Helpers

  subject { karafka.consumer_for(:other_topic) }

  it "does not route messages for a different topic to the subject" do
    karafka.produce('{"x":1}', topic: "test_topic")
    expect(subject.messages).to be_nil
  end
end

# When described_class is NOT a consumer class, implicit subject is not used
RSpec.describe "non-consumer context" do
  include Karafka::Testing::RSpec::Helpers

  it "works with explicit consumer_for via mappings" do
    consumer = karafka.consumer_for(:other_topic)
    karafka.produce('{"x":1}', topic: "other_topic")
    expect(consumer.messages.size).to eq(1)
  end
end
