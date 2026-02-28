# frozen_string_literal: true

require "test_helper"

class KarafkaTestingHelpersFindCandidateTopicsTest < Minitest::Test
  def setup
    @topic = mock("Topic")
    @topic.stubs(:name).returns("test_topic")

    @subscription_group = mock("SubscriptionGroup")
    @topic.stubs(:subscription_group).returns(@subscription_group)

    @topics = mock("Topics")
    @subscription_group.stubs(:topics).returns(@topics)

    Karafka::Testing::Helpers
      .stubs(:karafka_consumer_find_subscription_groups)
      .returns([@subscription_group])
  end

  def test_returns_matching_topics_when_found
    @topics.stubs(:find).with("test_topic").returns(@topic)

    result = Karafka::Testing::Helpers.karafka_consumer_find_candidate_topics(
      "test_topic", nil
    )

    assert_equal [@topic], result
  end

  def test_returns_empty_array_when_topic_not_found
    error_class = Class.new(StandardError)
    errors_existed = Karafka.const_defined?(:Errors, false)
    Karafka.const_set(:Errors, Module.new) unless errors_existed
    Karafka::Errors.const_set(:TopicNotFoundError, error_class)
    @topics.stubs(:find).with("unknown_topic").raises(error_class)

    result = Karafka::Testing::Helpers.karafka_consumer_find_candidate_topics(
      "unknown_topic", nil
    )

    assert_equal [], result
  ensure
    if defined?(Karafka::Errors::TopicNotFoundError)
      Karafka::Errors.send(:remove_const, :TopicNotFoundError)
    end
    Karafka.send(:remove_const, :Errors) unless errors_existed
  end

  def test_returns_empty_array_when_topic_returns_nil
    @topics.stubs(:find).with("nil_topic").returns(nil)

    result = Karafka::Testing::Helpers.karafka_consumer_find_candidate_topics(
      "nil_topic", nil
    )

    assert_equal [], result
  end
end

class KarafkaTestingHelpersFindSubscriptionGroupsTest < Minitest::Test
  def setup
    @consumer_group = mock("ConsumerGroup")
    @consumer_group.stubs(:name).returns("test_group")
    @subscription_groups = [mock("SubscriptionGroup")]
    @subscription_groups_hash = { @consumer_group => @subscription_groups }

    @original_app = Karafka.const_defined?(:App, false) ? Karafka::App : nil
    unless @original_app
      app = Class.new do
        def self.subscription_groups
          {}
        end
      end
      Karafka.const_set(:App, app)
    end
  end

  def teardown
    return if @original_app

    Karafka.send(:remove_const, :App) if Karafka.const_defined?(:App, false)
  end

  def test_returns_all_subscription_groups_when_not_specified
    Karafka::App.stubs(:subscription_groups).returns(@subscription_groups_hash)

    result = Karafka::Testing::Helpers.karafka_consumer_find_subscription_groups(nil)

    assert_equal @subscription_groups, result
  end

  def test_returns_all_subscription_groups_for_empty_string
    Karafka::App.stubs(:subscription_groups).returns(@subscription_groups_hash)

    result = Karafka::Testing::Helpers.karafka_consumer_find_subscription_groups("")

    assert_equal @subscription_groups, result
  end

  def test_returns_subscription_groups_for_specified_consumer_group
    Karafka::App.stubs(:subscription_groups).returns(@subscription_groups_hash)

    result = Karafka::Testing::Helpers.karafka_consumer_find_subscription_groups("test_group")

    assert_equal @subscription_groups, result
  end

  def test_raises_consumer_group_not_found_error_for_nonexistent_group
    Karafka::App.stubs(:subscription_groups).returns({})

    assert_raises(Karafka::Testing::Errors::ConsumerGroupNotFoundError) do
      Karafka::Testing::Helpers.karafka_consumer_find_subscription_groups("unknown_group")
    end
  end
end
