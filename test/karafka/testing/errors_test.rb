# frozen_string_literal: true

describe Karafka::Testing::Errors do
  describe "BaseError" do
    it "inherits from StandardError" do
      assert_operator Karafka::Testing::Errors::BaseError, :<, StandardError
    end
  end

  describe "TopicNotFoundError" do
    it "inherits from BaseError" do
      assert_operator Karafka::Testing::Errors::TopicNotFoundError,
        :<, Karafka::Testing::Errors::BaseError
    end

    it "can be raised with a message" do
      err = assert_raises(Karafka::Testing::Errors::TopicNotFoundError) do
        raise Karafka::Testing::Errors::TopicNotFoundError, "test_topic"
      end
      assert_equal "test_topic", err.message
    end
  end

  describe "TopicInManyConsumerGroupsError" do
    it "inherits from BaseError" do
      assert_operator Karafka::Testing::Errors::TopicInManyConsumerGroupsError,
        :<, Karafka::Testing::Errors::BaseError
    end

    it "can be raised with a message" do
      err = assert_raises(Karafka::Testing::Errors::TopicInManyConsumerGroupsError) do
        raise Karafka::Testing::Errors::TopicInManyConsumerGroupsError, "shared_topic"
      end
      assert_equal "shared_topic", err.message
    end
  end

  describe "ConsumerGroupNotFoundError" do
    it "inherits from BaseError" do
      assert_operator Karafka::Testing::Errors::ConsumerGroupNotFoundError,
        :<, Karafka::Testing::Errors::BaseError
    end

    it "can be raised with a message" do
      err = assert_raises(Karafka::Testing::Errors::ConsumerGroupNotFoundError) do
        raise Karafka::Testing::Errors::ConsumerGroupNotFoundError, "unknown_group"
      end
      assert_equal "unknown_group", err.message
    end
  end

  describe "KarafkaNotLoadedError" do
    it "inherits from BaseError" do
      assert_operator Karafka::Testing::Errors::KarafkaNotLoadedError,
        :<, Karafka::Testing::Errors::BaseError
    end

    it "can be raised with a message" do
      err = assert_raises(Karafka::Testing::Errors::KarafkaNotLoadedError) do
        raise Karafka::Testing::Errors::KarafkaNotLoadedError, "custom message"
      end
      assert_equal "custom message", err.message
    end
  end

  describe "KarafkaNotInitializedError" do
    it "inherits from BaseError" do
      assert_operator Karafka::Testing::Errors::KarafkaNotInitializedError,
        :<, Karafka::Testing::Errors::BaseError
    end

    it "can be raised with a message" do
      err = assert_raises(Karafka::Testing::Errors::KarafkaNotInitializedError) do
        raise Karafka::Testing::Errors::KarafkaNotInitializedError, "custom message"
      end
      assert_equal "custom message", err.message
    end
  end
end
