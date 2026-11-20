# frozen_string_literal: true

describe_current do
  let(:consumer) { Object.new }
  let(:topic) { stub(offset_metadata?: offset_metadata) }
  let(:offset_metadata) { true }

  context "when Pro is not loaded" do
    before { Karafka.stubs(:pro?).returns(false) }

    it "prepends no extension" do
      Karafka::Testing::Pro::Injector.inject(consumer, topic)

      refute_includes consumer.singleton_class.ancestors, Karafka::Testing::Pro::SpecOffsetMetadata
    end
  end

  context "when Pro is loaded" do
    before { Karafka.stubs(:pro?).returns(true) }

    it "prepends the extensions of the features the topic uses" do
      Karafka::Testing::Pro::Injector.inject(consumer, topic)

      assert_includes consumer.singleton_class.ancestors, Karafka::Testing::Pro::SpecOffsetMetadata
    end

    context "when the topic does not use offset metadata" do
      let(:offset_metadata) { false }

      it "does not prepend the offset metadata extension" do
        Karafka::Testing::Pro::Injector.inject(consumer, topic)

        refute_includes consumer.singleton_class.ancestors, Karafka::Testing::Pro::SpecOffsetMetadata
      end
    end
  end
end
