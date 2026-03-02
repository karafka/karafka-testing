# frozen_string_literal: true

require "test_helper"

describe Karafka::Testing::SpecProducerClient do
  let(:rspec_example) do
    mock("RSpec::Core::ExampleGroup").tap do |example|
      example.stubs(:_karafka_add_message_to_consumer_if_needed)
    end
  end
  let(:client) { Karafka::Testing::SpecProducerClient.new(rspec_example) }

  it "inherits from WaterDrop::Clients::Buffered" do
    assert_operator Karafka::Testing::SpecProducerClient, :<, WaterDrop::Clients::Buffered
  end

  describe "#initialize" do
    it "stores the rspec example" do
      assert_equal rspec_example, client.instance_variable_get(:@rspec)
    end
  end

  describe "#produce" do
    let(:produce_message) { { topic: "test_topic", payload: "test_payload" } }

    it "calls _karafka_add_message_to_consumer_if_needed on the rspec example" do
      rspec_example.expects(:_karafka_add_message_to_consumer_if_needed).with(produce_message)
      client.produce(produce_message)
    end

    it "adds the message to the buffer" do
      client.produce(produce_message)

      assert_includes client.messages, produce_message
    end
  end
end
