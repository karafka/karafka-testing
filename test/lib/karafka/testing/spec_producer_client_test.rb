# frozen_string_literal: true

describe_current do
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
    it "stores the test example" do
      assert_equal rspec_example, client.instance_variable_get(:@example)
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

    it "keeps every message when producing from many threads" do
      # Lazy lets are not thread-safe, so they are built before the threads start
      buffered = client
      message = produce_message

      Array.new(8) { Thread.new { 500.times { buffered.produce(message) } } }.each(&:join)

      assert_equal 4_000, buffered.messages.size
      assert_equal 4_000, buffered.messages_for("test_topic").size
    end
  end

  describe "transactions" do
    let(:produce_message) { { topic: "test_topic", payload: "test_payload" } }

    it "moves the messages to the buffer on commit" do
      client.begin_transaction
      client.produce(produce_message)

      assert_empty client.messages

      client.commit_transaction

      assert_equal [produce_message], client.messages
    end

    it "drops the messages on abort" do
      client.begin_transaction
      client.produce(produce_message)
      client.abort_transaction

      assert_empty client.messages
    end
  end

  describe "#reset" do
    it "clears the buffer" do
      client.produce({ topic: "test_topic", payload: "test_payload" })
      client.reset

      assert_empty client.messages
      assert_empty client.messages_for("test_topic")
    end
  end
end
