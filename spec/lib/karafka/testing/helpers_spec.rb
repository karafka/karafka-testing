# frozen_string_literal: true

RSpec.describe_current do
  describe ".karafka_consumer_find_candidate_topics" do
    let(:topic) { double("Topic", name: "test_topic", subscription_group: subscription_group) }
    let(:subscription_group) { double("SubscriptionGroup", name: "test_group") }
    let(:topics) { double("Topics") }

    before do
      allow(described_class).to receive(:karafka_consumer_find_subscription_groups)
        .and_return([subscription_group])
      allow(subscription_group).to receive(:topics).and_return(topics)
    end

    context "when topic is found" do
      before do
        allow(topics).to receive(:find).with("test_topic").and_return(topic)
      end

      it "returns matching topics" do
        result = described_class.karafka_consumer_find_candidate_topics("test_topic", nil)

        expect(result).to eq([topic])
      end
    end

    context "when topic is not found" do
      before do
        error_class = Class.new(StandardError)
        stub_const("Karafka::Errors::TopicNotFoundError", error_class)
        allow(topics).to receive(:find).with("unknown_topic")
          .and_raise(Karafka::Errors::TopicNotFoundError)
      end

      it "returns empty array" do
        result = described_class.karafka_consumer_find_candidate_topics("unknown_topic", nil)

        expect(result).to eq([])
      end
    end

    context "when topic returns nil" do
      before do
        allow(topics).to receive(:find).with("nil_topic").and_return(nil)
      end

      it "returns empty array" do
        result = described_class.karafka_consumer_find_candidate_topics("nil_topic", nil)

        expect(result).to eq([])
      end
    end
  end

  describe ".karafka_consumer_find_subscription_groups" do
    let(:consumer_group) { double("ConsumerGroup", name: "test_group") }
    let(:subscription_groups) { [double("SubscriptionGroup")] }
    let(:subscription_groups_hash) { { consumer_group => subscription_groups } }

    before do
      stub_const("Karafka::App", Class.new do
        def self.subscription_groups
          {}
        end
      end)
    end

    context "when consumer group is not specified" do
      before do
        allow(Karafka::App).to receive(:subscription_groups).and_return(subscription_groups_hash)
      end

      it "returns all subscription groups" do
        result = described_class.karafka_consumer_find_subscription_groups(nil)

        expect(result).to eq(subscription_groups)
      end

      it "returns all subscription groups for empty string" do
        result = described_class.karafka_consumer_find_subscription_groups("")

        expect(result).to eq(subscription_groups)
      end
    end

    context "when consumer group is specified and exists" do
      before do
        allow(Karafka::App).to receive(:subscription_groups).and_return(subscription_groups_hash)
      end

      it "returns subscription groups for that consumer group" do
        result = described_class.karafka_consumer_find_subscription_groups("test_group")

        expect(result).to eq(subscription_groups)
      end
    end

    context "when consumer group is specified but does not exist" do
      before do
        allow(Karafka::App).to receive(:subscription_groups).and_return({})
      end

      it "raises ConsumerGroupNotFoundError" do
        expect do
          described_class.karafka_consumer_find_subscription_groups("unknown_group")
        end.to raise_error(Karafka::Testing::Errors::ConsumerGroupNotFoundError)
      end
    end
  end
end
