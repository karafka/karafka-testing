# frozen_string_literal: true

describe_current do
  let(:consumer_class) do
    Class.new do
      def offset_metadata(cache: true)
        raise "real fetcher called with cache: #{cache}"
      end

      alias_method :committed_offset_metadata, :offset_metadata
    end
  end

  let(:consumer) { consumer_class.new.tap { |c| c.singleton_class.prepend(Karafka::Testing::SpecOffsetMetadata) } }
  let(:client) { Karafka::Testing::SpecConsumerClient.new }
  let(:deserializer) { ->(raw) { raw ? "deserialized #{raw}" : "none" } }

  before do
    consumer.stubs(:client).returns(client)
    consumer.stubs(:topic).returns(stub(offset_metadata: stub(deserializer: deserializer)))
  end

  context "when the partition is owned" do
    before { consumer.stubs(:revoked?).returns(false) }

    it "deserializes the client offset metadata" do
      client.offset_metadata = "meta"

      assert_equal "deserialized meta", consumer.offset_metadata
      assert_equal "deserialized meta", consumer.offset_metadata(cache: false)
      assert_equal "deserialized meta", consumer.committed_offset_metadata
    end

    it "deserializes nil when no offset metadata was set" do
      assert_equal "none", consumer.offset_metadata
    end
  end

  context "when the partition is revoked" do
    before { consumer.stubs(:revoked?).returns(true) }

    it "returns false" do
      client.offset_metadata = "meta"

      refute consumer.offset_metadata
    end
  end
end
