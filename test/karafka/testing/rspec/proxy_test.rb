# frozen_string_literal: true

describe Karafka::Testing::RSpec::Proxy do
  let(:rspec_example) { stub_everything("RSpec::ExampleGroups") }
  let(:proxy) { Karafka::Testing::RSpec::Proxy.new(rspec_example) }

  describe "#initialize" do
    it "stores the rspec example" do
      assert_equal rspec_example, proxy.instance_variable_get(:@rspec_example)
    end
  end

  describe "#consumer_for" do
    it "delegates to _karafka_consumer_for" do
      rspec_example.expects(:_karafka_consumer_for).with(:test_topic)
      proxy.consumer_for(:test_topic)
    end

    it "passes all arguments" do
      rspec_example.expects(:_karafka_consumer_for).with(:test_topic, :test_group)
      proxy.consumer_for(:test_topic, :test_group)
    end
  end

  describe "#produce" do
    it "delegates to _karafka_produce" do
      rspec_example.expects(:_karafka_produce).with("payload")
      proxy.produce("payload")
    end

    it "passes all arguments" do
      rspec_example.expects(:_karafka_produce).with("payload", { partition: 1 })
      proxy.produce("payload", partition: 1)
    end
  end

  describe "#produce_to" do
    let(:consumer_instance) { mock("consumer") }

    it "delegates to _karafka_produce_to" do
      rspec_example.expects(:_karafka_produce_to).with(consumer_instance, "payload")
      proxy.produce_to(consumer_instance, "payload")
    end

    it "passes all arguments including metadata" do
      rspec_example.expects(:_karafka_produce_to)
        .with(consumer_instance, "payload", { partition: 2 })
      proxy.produce_to(consumer_instance, "payload", partition: 2)
    end
  end

  describe "#produced_messages" do
    it "delegates to _karafka_produced_messages" do
      rspec_example.expects(:_karafka_produced_messages).returns([])
      proxy.produced_messages
    end

    it "returns the messages from the example" do
      messages = [{ topic: "test", payload: "data" }]
      rspec_example.stubs(:_karafka_produced_messages).returns(messages)

      assert_equal messages, proxy.produced_messages
    end
  end

  describe "#consumer_messages" do
    it "delegates to _karafka_consumer_messages" do
      rspec_example.expects(:_karafka_consumer_messages).returns([])
      proxy.consumer_messages
    end

    it "returns the messages from the example" do
      messages = %w[message1 message2]
      rspec_example.stubs(:_karafka_consumer_messages).returns(messages)

      assert_equal messages, proxy.consumer_messages
    end
  end
end
