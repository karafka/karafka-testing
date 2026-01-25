# frozen_string_literal: true

RSpec.describe_current do
  describe "BaseError" do
    subject(:error) { described_class::BaseError }

    it { expect(error).to be < StandardError }
  end

  describe "TopicNotFoundError" do
    subject(:error) { described_class::TopicNotFoundError }

    it { expect(error).to be < described_class::BaseError }

    it "can be raised with a message" do
      expect { raise error, "test_topic" }.to raise_error(error, "test_topic")
    end
  end

  describe "TopicInManyConsumerGroupsError" do
    subject(:error) { described_class::TopicInManyConsumerGroupsError }

    it { expect(error).to be < described_class::BaseError }

    it "can be raised with a message" do
      expect { raise error, "shared_topic" }.to raise_error(error, "shared_topic")
    end
  end

  describe "ConsumerGroupNotFoundError" do
    subject(:error) { described_class::ConsumerGroupNotFoundError }

    it { expect(error).to be < described_class::BaseError }

    it "can be raised with a message" do
      expect { raise error, "unknown_group" }.to raise_error(error, "unknown_group")
    end
  end

  describe "KarafkaNotLoadedError" do
    subject(:error) { described_class::KarafkaNotLoadedError }

    it { expect(error).to be < described_class::BaseError }

    it "can be raised with a message" do
      expect { raise error, "custom message" }.to raise_error(error, "custom message")
    end
  end

  describe "KarafkaNotInitializedError" do
    subject(:error) { described_class::KarafkaNotInitializedError }

    it { expect(error).to be < described_class::BaseError }

    it "can be raised with a message" do
      expect { raise error, "custom message" }.to raise_error(error, "custom message")
    end
  end
end
