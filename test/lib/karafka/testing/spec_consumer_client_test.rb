# frozen_string_literal: true

describe_current do
  let(:client) { Karafka::Testing::SpecConsumerClient.new }

  let(:marked_message) { stub(topic: "topic", partition: 1, offset: 10) }

  describe "#mark_as_consumed" do
    it "returns true" do
      assert client.mark_as_consumed(marked_message)
    end

    it "records the mark with its metadata" do
      client.mark_as_consumed(marked_message, "meta")

      assert_equal [{ topic: "topic", partition: 1, offset: 10, metadata: "meta" }], client.marks
    end

    it "records the mark without metadata" do
      client.mark_as_consumed(marked_message)

      assert_equal [{ topic: "topic", partition: 1, offset: 10, metadata: nil }], client.marks
    end
  end

  describe "#mark_as_consumed!" do
    it "returns true" do
      assert client.mark_as_consumed!(marked_message)
    end

    it "records the mark with its metadata" do
      client.mark_as_consumed!(marked_message, "meta")

      assert_equal [{ topic: "topic", partition: 1, offset: 10, metadata: "meta" }], client.marks
    end
  end

  describe "#marks" do
    it "is empty for a new client" do
      assert_empty client.marks
    end
  end

  describe "#offset_metadata" do
    it "is nil for a new client" do
      assert_nil client.offset_metadata
    end

    it "returns the assigned metadata" do
      client.offset_metadata = "meta"

      assert_equal "meta", client.offset_metadata
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

  describe "#pause" do
    it "returns true" do
      assert client.pause("topic", 0, 100, 5_000)
    end

    it "records the pause" do
      client.pause("topic", 1, 100, 5_000)

      assert_equal [{ topic: "topic", partition: 1, offset: 100, timeout: 5_000 }], client.pauses
    end

    it "records a pause without offset and timeout" do
      client.pause("topic", 0)

      assert_equal [{ topic: "topic", partition: 0, offset: nil, timeout: 0 }], client.pauses
    end
  end

  describe "#resume" do
    it "returns true" do
      assert client.resume("topic", 0)
    end

    it "records the resume" do
      client.resume("topic", 2)

      assert_equal [{ topic: "topic", partition: 2 }], client.resumes
    end
  end

  describe "#pauses and #resumes" do
    it "are empty for a new client" do
      assert_empty client.pauses
      assert_empty client.resumes
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
