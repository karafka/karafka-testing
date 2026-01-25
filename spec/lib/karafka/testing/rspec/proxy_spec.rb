# frozen_string_literal: true

RSpec.describe Karafka::Testing::RSpec::Proxy do
  subject(:proxy) { described_class.new(rspec_example) }

  let(:rspec_example) do
    double("RSpec::ExampleGroups").tap do |example|
      allow(example).to receive(:_karafka_consumer_for)
      allow(example).to receive(:_karafka_produce)
      allow(example).to receive(:_karafka_produce_to)
      allow(example).to receive_messages(_karafka_produced_messages: [], _karafka_consumer_messages: [])
    end
  end

  describe "#initialize" do
    it "stores the rspec example" do
      expect(proxy.instance_variable_get(:@rspec_example)).to eq(rspec_example)
    end
  end

  describe "#consumer_for" do
    it "delegates to _karafka_consumer_for" do
      proxy.consumer_for(:test_topic)

      expect(rspec_example).to have_received(:_karafka_consumer_for).with(:test_topic)
    end

    it "passes all arguments" do
      proxy.consumer_for(:test_topic, :test_group)

      expect(rspec_example).to have_received(:_karafka_consumer_for)
        .with(:test_topic, :test_group)
    end
  end

  describe "#produce" do
    it "delegates to _karafka_produce" do
      proxy.produce("payload")

      expect(rspec_example).to have_received(:_karafka_produce).with("payload")
    end

    it "passes all arguments" do
      proxy.produce("payload", partition: 1)

      expect(rspec_example).to have_received(:_karafka_produce)
        .with("payload", partition: 1)
    end
  end

  describe "#produce_to" do
    let(:consumer_instance) { double("consumer") }

    it "delegates to _karafka_produce_to" do
      proxy.produce_to(consumer_instance, "payload")

      expect(rspec_example).to have_received(:_karafka_produce_to)
        .with(consumer_instance, "payload")
    end

    it "passes all arguments including metadata" do
      proxy.produce_to(consumer_instance, "payload", partition: 2)

      expect(rspec_example).to have_received(:_karafka_produce_to)
        .with(consumer_instance, "payload", partition: 2)
    end
  end

  describe "#produced_messages" do
    it "delegates to _karafka_produced_messages" do
      proxy.produced_messages

      expect(rspec_example).to have_received(:_karafka_produced_messages)
    end

    it "returns the messages from the example" do
      messages = [{ topic: "test", payload: "data" }]
      allow(rspec_example).to receive(:_karafka_produced_messages).and_return(messages)

      expect(proxy.produced_messages).to eq(messages)
    end
  end

  describe "#consumer_messages" do
    it "delegates to _karafka_consumer_messages" do
      proxy.consumer_messages

      expect(rspec_example).to have_received(:_karafka_consumer_messages)
    end

    it "returns the messages from the example" do
      messages = %w[message1 message2]
      allow(rspec_example).to receive(:_karafka_consumer_messages).and_return(messages)

      expect(proxy.consumer_messages).to eq(messages)
    end
  end
end
