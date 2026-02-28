# frozen_string_literal: true

class KarafkaTestingSpecProducerClientTest < Minitest::Test
  def setup
    @rspec_example = mock("RSpec::Core::ExampleGroup")
    @rspec_example.stubs(:_karafka_add_message_to_consumer_if_needed)
    @client = Karafka::Testing::SpecProducerClient.new(@rspec_example)
  end

  def test_inherits_from_waterdrop_buffered_client
    assert_operator Karafka::Testing::SpecProducerClient, :<, WaterDrop::Clients::Buffered
  end

  def test_stores_the_rspec_example
    assert_equal @rspec_example, @client.instance_variable_get(:@rspec)
  end

  def test_produce_calls_add_message_on_rspec_example
    message = { topic: "test_topic", payload: "test_payload" }

    @rspec_example.expects(:_karafka_add_message_to_consumer_if_needed).with(message)

    @client.produce(message)
  end

  def test_produce_adds_message_to_buffer
    message = { topic: "test_topic", payload: "test_payload" }

    @client.produce(message)

    assert_includes @client.messages, message
  end
end
