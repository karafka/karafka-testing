# frozen_string_literal: true

require_relative "consumers/test_consumer"
require_relative "consumers/other_consumer"

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

  consumer_group :secondary_group do
    topic :test_topic do
      consumer OtherConsumer
    end
  end
end
