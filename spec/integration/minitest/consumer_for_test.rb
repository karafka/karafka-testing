# frozen_string_literal: true

require_relative "../minitest_helper"

class ConsumerForTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def test_returns_instance_of_configured_consumer_class
    consumer = @karafka.consumer_for(:test_topic, :test_group)
    assert_kind_of TestConsumer, consumer
  end

  def test_assigns_correct_topic_to_consumer
    consumer = @karafka.consumer_for(:test_topic, :test_group)
    assert_equal "test_topic", consumer.topic.name
  end

  def test_provides_mock_client_on_consumer
    consumer = @karafka.consumer_for(:test_topic, :test_group)
    assert_kind_of Karafka::Testing::SpecConsumerClient, consumer.client
  end

  def test_assigns_producer_to_consumer
    consumer = @karafka.consumer_for(:test_topic, :test_group)
    assert_equal Karafka::App.producer, consumer.producer
  end

  def test_raises_topic_not_found_error_for_nonexistent_topic
    assert_raises(Karafka::Testing::Errors::TopicNotFoundError) do
      @karafka.consumer_for(:nonexistent_topic)
    end
  end

  def test_raises_topic_in_many_consumer_groups_error_without_disambiguation
    assert_raises(Karafka::Testing::Errors::TopicInManyConsumerGroupsError) do
      @karafka.consumer_for(:test_topic)
    end
  end

  def test_works_with_consumer_group_disambiguation
    consumer = @karafka.consumer_for(:test_topic, :secondary_group)
    assert_kind_of OtherConsumer, consumer
    assert_equal "test_topic", consumer.topic.name
  end

  def test_raises_consumer_group_not_found_error_for_nonexistent_group
    assert_raises(Karafka::Testing::Errors::ConsumerGroupNotFoundError) do
      @karafka.consumer_for(:test_topic, :nonexistent_group)
    end
  end
end
