# frozen_string_literal: true

Karafka::App.setup do |config|
  config.kafka = { "bootstrap.servers": "localhost:9092" }
  config.group_id = "test_group"
end

Karafka::App.routes.draw do
  topic :test_topic do
    consumer TestConsumer
  end

  topic :other_topic do
    consumer OtherConsumer
  end

  topic :pausing_topic do
    consumer PausingConsumer
  end

  consumer_group :secondary_group do
    topic :test_topic do
      consumer OtherConsumer
    end
  end
end
