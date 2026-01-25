# frozen_string_literal: true

RSpec.describe_current do
  subject(:client) { described_class.new(rspec_example) }

  let(:rspec_example) do
    double("RSpec::Core::ExampleGroup").tap do |example|
      allow(example).to receive(:_karafka_add_message_to_consumer_if_needed)
    end
  end

  it { expect(described_class).to be < WaterDrop::Clients::Buffered }

  describe "#initialize" do
    it "stores the rspec example" do
      expect(client.instance_variable_get(:@rspec)).to eq(rspec_example)
    end
  end

  describe "#produce" do
    let(:message) { { topic: "test_topic", payload: "test_payload" } }

    it "calls _karafka_add_message_to_consumer_if_needed on the rspec example" do
      client.produce(message)

      expect(rspec_example).to have_received(:_karafka_add_message_to_consumer_if_needed)
        .with(message)
    end

    it "adds the message to the buffer" do
      client.produce(message)

      expect(client.messages).to include(message)
    end
  end
end
