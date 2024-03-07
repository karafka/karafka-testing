# frozen_string_literal: true

# Main module to encapsulate logic
module Karafka
  module Testing
    # Errors that can be raised by this lib
    module Errors
      # Base error for all the internal errors
      BaseError = Class.new(StandardError)

      # Raised when we want to build a consumer for a topic that does not exist
      TopicNotFoundError = Class.new(BaseError)

      # Raised when topic is in many consumer groups and not limited by consumer group expectation
      TopicInManyConsumerGroupsError = Class.new(BaseError)

      # Raised when you requested a topic from a consumer group that does not exist
      ConsumerGroupNotFoundError = Class.new(BaseError)

      # Raised when trying to use testing without Karafka app being visible
      # If you are seeing this error, then you tried to use testing helpers without Karafka being
      # loaded prior to this happening.
      KarafkaNotLoadedError = Class.new(BaseError)

      # Raised when there is an attempt to use the testing primitives without Karafka app being
      # configured. Prior to initialization process, most of config values are nils, etc and
      # mocks will not work.
      KarafkaNotInitializedError = Class.new(BaseError)
    end
  end
end
