# frozen_string_literal: true

RSpec.describe_current do
  subject(:client) { described_class.new }

  describe "#mark_as_consumed" do
    it "returns true" do
      expect(client.mark_as_consumed).to be(true)
    end

    it "accepts any arguments" do
      expect(client.mark_as_consumed("arg1", "arg2")).to be(true)
    end
  end

  describe "#mark_as_consumed!" do
    it "returns true" do
      expect(client.mark_as_consumed!).to be(true)
    end

    it "accepts any arguments" do
      expect(client.mark_as_consumed!("arg1")).to be(true)
    end
  end

  describe "#commit_offsets" do
    it "returns true" do
      expect(client.commit_offsets).to be(true)
    end

    it "accepts any arguments" do
      expect(client.commit_offsets("arg1")).to be(true)
    end
  end

  describe "#commit_offsets!" do
    it "returns true" do
      expect(client.commit_offsets!).to be(true)
    end

    it "accepts any arguments" do
      expect(client.commit_offsets!("arg1", "arg2")).to be(true)
    end
  end

  describe "#seek" do
    it "returns true" do
      expect(client.seek).to be(true)
    end

    it "accepts any arguments" do
      expect(client.seek("topic", 0, 100)).to be(true)
    end
  end

  describe "#consumer_group_metadata_pointer" do
    it "returns true" do
      expect(client.consumer_group_metadata_pointer).to be(true)
    end
  end

  describe "#assignment_lost?" do
    it "always returns false" do
      expect(client.assignment_lost?).to be(false)
    end
  end
end
