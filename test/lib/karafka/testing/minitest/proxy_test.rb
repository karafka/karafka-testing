# frozen_string_literal: true

class KarafkaTestingMinitestProxyTest < Minitest::Test
  def setup
    @minitest_example = mock("Minitest::Test")
    @proxy = Karafka::Testing::Minitest::Proxy.new(@minitest_example)
  end

  def test_stores_the_minitest_example
    assert_equal @minitest_example, @proxy.instance_variable_get(:@minitest_example)
  end

  def test_consumer_for_delegates_to_karafka_consumer_for
    @minitest_example.expects(:_karafka_consumer_for).with(:test_topic)

    @proxy.consumer_for(:test_topic)
  end

  def test_consumer_for_passes_all_arguments
    @minitest_example.expects(:_karafka_consumer_for).with(:test_topic, :test_group)

    @proxy.consumer_for(:test_topic, :test_group)
  end

  def test_produce_delegates_to_karafka_produce
    @minitest_example.expects(:_karafka_produce).with("payload")

    @proxy.produce("payload")
  end

  def test_produce_passes_all_arguments
    @minitest_example.expects(:_karafka_produce).once

    @proxy.produce("payload", partition: 1)
  end

  def test_produce_to_delegates_to_karafka_produce_to
    consumer_instance = mock("consumer")

    @minitest_example.expects(:_karafka_produce_to).with(consumer_instance, "payload")

    @proxy.produce_to(consumer_instance, "payload")
  end

  def test_produce_to_passes_all_arguments_including_metadata
    consumer_instance = mock("consumer")

    @minitest_example.expects(:_karafka_produce_to).once

    @proxy.produce_to(consumer_instance, "payload", partition: 2)
  end

  def test_produced_messages_delegates_to_karafka_produced_messages
    @minitest_example.expects(:_karafka_produced_messages).returns([])

    @proxy.produced_messages
  end

  def test_produced_messages_returns_messages_from_example
    messages = [{ topic: "test", payload: "data" }]
    @minitest_example.stubs(:_karafka_produced_messages).returns(messages)

    assert_equal messages, @proxy.produced_messages
  end

  def test_consumer_messages_delegates_to_karafka_consumer_messages
    @minitest_example.expects(:_karafka_consumer_messages).returns([])

    @proxy.consumer_messages
  end

  def test_consumer_messages_returns_messages_from_example
    messages = %w[message1 message2]
    @minitest_example.stubs(:_karafka_consumer_messages).returns(messages)

    assert_equal messages, @proxy.consumer_messages
  end
end
