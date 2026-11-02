# frozen_string_literal: true

describe_current do
  let(:consumer_class) do
    Class.new do
      attr_reader :resumed

      def resume
        @resumed = true
      end
    end
  end

  let(:consumer) { consumer_class.new.tap { |c| c.singleton_class.prepend(Karafka::Testing::SpecConsumerResume) } }
  let(:client) { Karafka::Testing::SpecConsumerClient.new }
  let(:pause_tracker) { stub("PauseTracker") }

  before do
    consumer.stubs(:client).returns(client)
    consumer.stubs(:coordinator).returns(stub(pause_tracker: pause_tracker))
    consumer.stubs(:topic).returns(stub(name: "topic"))
    consumer.stubs(:partition).returns(3)
  end

  context "when the consumer is paused" do
    before { pause_tracker.stubs(:paused?).returns(true) }

    it "resumes the pause tracker and the partition on the client" do
      pause_tracker.expects(:resume)

      consumer.resume

      assert consumer.resumed
      assert_equal [{ topic: "topic", partition: 3 }], client.resumes
    end
  end

  context "when the consumer is not paused" do
    before { pause_tracker.stubs(:paused?).returns(false) }

    it "does not resume the partition on the client" do
      pause_tracker.expects(:resume).never

      consumer.resume

      assert consumer.resumed
      assert_empty client.resumes
    end
  end
end
