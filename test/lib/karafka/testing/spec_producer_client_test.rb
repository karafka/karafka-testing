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

  describe "transactional marks" do
    let(:consumer_client) { Karafka::Testing::SpecConsumerClient.new }
    let(:tpl) { stub(to_h: { "test_topic" => [stub(partition: 1, offset: 11, metadata: "meta")] }) }

    before do
      client.begin_transaction
      client.send_offsets_to_transaction(consumer_client, tpl, 1_000)
    end

    it "records the marks on the consumer client on commit" do
      assert_empty consumer_client.marks

      client.commit_transaction

      assert_equal(
        [{ topic: "test_topic", partition: 1, offset: 10, metadata: "meta" }],
        consumer_client.marks
      )
    end

    it "drops the marks on abort" do
      client.abort_transaction
      client.begin_transaction
      client.commit_transaction

      assert_empty consumer_client.marks
    end

    it "drops the marks on reset" do
      client.reset
      client.begin_transaction
      client.commit_transaction

      assert_empty consumer_client.marks
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
