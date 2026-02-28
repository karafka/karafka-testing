# frozen_string_literal: true

require "test_helper"

module KarafkaTestingErrorsTests
  ERRORS = Karafka::Testing::Errors

  class BaseErrorTest < Minitest::Test
    def test_inherits_from_standard_error
      assert_operator ERRORS::BaseError, :<, StandardError
    end
  end

  class TopicNotFoundErrorTest < Minitest::Test
    def test_inherits_from_base_error
      assert_operator ERRORS::TopicNotFoundError, :<, ERRORS::BaseError
    end

    def test_can_be_raised_with_a_message
      error = assert_raises(ERRORS::TopicNotFoundError) do
        raise ERRORS::TopicNotFoundError, "test_topic"
      end

      assert_equal "test_topic", error.message
    end
  end

  class TopicInManyConsumerGroupsErrorTest < Minitest::Test
    def test_inherits_from_base_error
      assert_operator ERRORS::TopicInManyConsumerGroupsError, :<, ERRORS::BaseError
    end

    def test_can_be_raised_with_a_message
      error = assert_raises(ERRORS::TopicInManyConsumerGroupsError) do
        raise ERRORS::TopicInManyConsumerGroupsError, "shared_topic"
      end

      assert_equal "shared_topic", error.message
    end
  end

  class ConsumerGroupNotFoundErrorTest < Minitest::Test
    def test_inherits_from_base_error
      assert_operator ERRORS::ConsumerGroupNotFoundError, :<, ERRORS::BaseError
    end

    def test_can_be_raised_with_a_message
      error = assert_raises(ERRORS::ConsumerGroupNotFoundError) do
        raise ERRORS::ConsumerGroupNotFoundError, "unknown_group"
      end

      assert_equal "unknown_group", error.message
    end
  end

  class KarafkaNotLoadedErrorTest < Minitest::Test
    def test_inherits_from_base_error
      assert_operator ERRORS::KarafkaNotLoadedError, :<, ERRORS::BaseError
    end

    def test_can_be_raised_with_a_message
      error = assert_raises(ERRORS::KarafkaNotLoadedError) do
        raise ERRORS::KarafkaNotLoadedError, "custom message"
      end

      assert_equal "custom message", error.message
    end
  end

  class KarafkaNotInitializedErrorTest < Minitest::Test
    def test_inherits_from_base_error
      assert_operator ERRORS::KarafkaNotInitializedError, :<, ERRORS::BaseError
    end

    def test_can_be_raised_with_a_message
      error = assert_raises(ERRORS::KarafkaNotInitializedError) do
        raise ERRORS::KarafkaNotInitializedError, "custom message"
      end

      assert_equal "custom message", error.message
    end
  end
end
