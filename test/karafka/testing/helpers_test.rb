# frozen_string_literal: true

describe Karafka::Testing::Helpers do
  describe ".karafka_consumer_find_candidate_topics" do
    let(:subscription_group) { stub_everything("SubscriptionGroup") }
    let(:topic) { stub_everything("Topic") }
    let(:topics) { stub_everything("Topics") }

    before do
      topic.stubs(:name).returns("test_topic")
      topic.stubs(:subscription_group).returns(subscription_group)
      subscription_group.stubs(:name).returns("test_group")
      Karafka::Testing::Helpers.stubs(:karafka_consumer_find_subscription_groups)
        .returns([subscription_group])
      subscription_group.stubs(:topics).returns(topics)
    end

    context "when topic is found" do
      before do
        topics.stubs(:find).with("test_topic").returns(topic)
      end

      it "returns matching topics" do
        result = Karafka::Testing::Helpers.karafka_consumer_find_candidate_topics(
          "test_topic", nil
        )

        assert_equal [topic], result
      end
    end

    context "when topic is not found" do
      before do
        error_class = Class.new(StandardError)
        stub_const("Karafka::Errors::TopicNotFoundError", error_class)
        topics.stubs(:find).with("unknown_topic")
          .raises(Karafka::Errors::TopicNotFoundError)
      end

      it "returns empty array" do
        result = Karafka::Testing::Helpers.karafka_consumer_find_candidate_topics(
          "unknown_topic", nil
        )

        assert_equal [], result
      end
    end

    context "when topic returns nil" do
      before do
        topics.stubs(:find).with("nil_topic").returns(nil)
      end

      it "returns empty array" do
        result = Karafka::Testing::Helpers.karafka_consumer_find_candidate_topics(
          "nil_topic", nil
        )

        assert_equal [], result
      end
    end
  end

  describe ".karafka_consumer_find_subscription_groups" do
    let(:consumer_group) { stub_everything("ConsumerGroup") }
    let(:subscription_groups) { [stub_everything("SubscriptionGroup")] }
    let(:subscription_groups_hash) { { consumer_group => subscription_groups } }

    before do
      consumer_group.stubs(:name).returns("test_group")
      stub_const("Karafka::App", Class.new {
        def self.subscription_groups
          {}
        end
      })
    end

    context "when consumer group is not specified" do
      before do
        Karafka::App.stubs(:subscription_groups).returns(subscription_groups_hash)
      end

      it "returns all subscription groups" do
        result = Karafka::Testing::Helpers.karafka_consumer_find_subscription_groups(nil)

        assert_equal subscription_groups, result
      end

      it "returns all subscription groups for empty string" do
        result = Karafka::Testing::Helpers.karafka_consumer_find_subscription_groups("")

        assert_equal subscription_groups, result
      end
    end

    context "when consumer group is specified and exists" do
      before do
        Karafka::App.stubs(:subscription_groups).returns(subscription_groups_hash)
      end

      it "returns subscription groups for that consumer group" do
        result = Karafka::Testing::Helpers.karafka_consumer_find_subscription_groups(
          "test_group"
        )

        assert_equal subscription_groups, result
      end
    end

    context "when consumer group is specified but does not exist" do
      before do
        Karafka::App.stubs(:subscription_groups).returns({})
      end

      it "raises ConsumerGroupNotFoundError" do
        assert_raises(Karafka::Testing::Errors::ConsumerGroupNotFoundError) do
          Karafka::Testing::Helpers.karafka_consumer_find_subscription_groups("unknown_group")
        end
      end
    end
  end
end
