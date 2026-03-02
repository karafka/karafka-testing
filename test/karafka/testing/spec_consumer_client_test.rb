# frozen_string_literal: true

describe Karafka::Testing::SpecConsumerClient do
  let(:client) { Karafka::Testing::SpecConsumerClient.new }

  describe "#mark_as_consumed" do
    it "returns true" do
      assert client.mark_as_consumed
    end

    it "accepts any arguments" do
      assert client.mark_as_consumed("arg1", "arg2")
    end
  end

  describe "#mark_as_consumed!" do
    it "returns true" do
      assert client.mark_as_consumed!
    end

    it "accepts any arguments" do
      assert client.mark_as_consumed!("arg1")
    end
  end

  describe "#commit_offsets" do
    it "returns true" do
      assert client.commit_offsets
    end

    it "accepts any arguments" do
      assert client.commit_offsets("arg1")
    end
  end

  describe "#commit_offsets!" do
    it "returns true" do
      assert client.commit_offsets!
    end

    it "accepts any arguments" do
      assert client.commit_offsets!("arg1", "arg2")
    end
  end

  describe "#seek" do
    it "returns true" do
      assert client.seek
    end

    it "accepts any arguments" do
      assert client.seek("topic", 0, 100)
    end
  end

  describe "#consumer_group_metadata_pointer" do
    it "returns true" do
      assert client.consumer_group_metadata_pointer
    end
  end

  describe "#assignment_lost?" do
    it "always returns false" do
      refute_predicate client, :assignment_lost?
    end
  end
end
