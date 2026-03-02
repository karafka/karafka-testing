# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "consumer_for" do
  include Karafka::Testing::RSpec::Helpers

  it "returns an instance of the configured consumer class" do
    consumer = karafka.consumer_for(:test_topic, :test_group)
    expect(consumer).to be_a(TestConsumer)
  end

  it "assigns the correct topic to the consumer" do
    consumer = karafka.consumer_for(:test_topic, :test_group)
    expect(consumer.topic.name).to eq("test_topic")
  end

  it "provides a mock client on the consumer" do
    consumer = karafka.consumer_for(:test_topic, :test_group)
    expect(consumer.client).to be_a(Karafka::Testing::SpecConsumerClient)
  end

  it "assigns a producer to the consumer" do
    consumer = karafka.consumer_for(:test_topic, :test_group)
    expect(consumer.producer).to eq(Karafka::App.producer)
  end

  it "raises TopicNotFoundError for a non-existent topic" do
    expect { karafka.consumer_for(:nonexistent_topic) }
      .to raise_error(Karafka::Testing::Errors::TopicNotFoundError)
  end

  it "raises TopicInManyConsumerGroupsError without group disambiguation" do
    expect { karafka.consumer_for(:test_topic) }
      .to raise_error(Karafka::Testing::Errors::TopicInManyConsumerGroupsError)
  end

  it "works with consumer group disambiguation" do
    consumer = karafka.consumer_for(:test_topic, :secondary_group)
    expect(consumer).to be_a(OtherConsumer)
    expect(consumer.topic.name).to eq("test_topic")
  end

  it "raises ConsumerGroupNotFoundError for a non-existent group" do
    expect { karafka.consumer_for(:test_topic, :nonexistent_group) }
      .to raise_error(Karafka::Testing::Errors::ConsumerGroupNotFoundError)
  end
end
