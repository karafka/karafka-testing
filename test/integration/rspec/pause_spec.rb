# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "pausing" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:pausing_topic) }

  let(:pause_tracker) { consumer.coordinator.pause_tracker }

  it "pauses without raising" do
    3.times { |i| karafka.produce({ "i" => i }.to_json) }

    expect { consumer.consume }.not_to raise_error
    expect(pause_tracker).to be_paused
  end

  it "does not pause when the consumer does not ask for it" do
    karafka.produce({ "i" => 0 }.to_json)

    consumer.consume

    expect(pause_tracker).not_to be_paused
  end

  it "resumes after a pause" do
    3.times { karafka.produce({ "resume" => true }.to_json) }

    consumer.consume

    expect(pause_tracker).to be_expired
  end

  it "records pauses" do
    3.times { |i| karafka.produce({ "i" => i }.to_json) }

    consumer.consume

    expect(karafka.pauses).to eq(
      [{ topic: "pausing_topic", partition: 0, offset: 2, timeout: 5_000 }]
    )
    expect(karafka.resumes).to be_empty
  end

  it "records resumes of paused consumers" do
    3.times { karafka.produce({ "resume" => true }.to_json) }

    consumer.consume

    expect(karafka.resumes).to eq([{ topic: "pausing_topic", partition: 0 }])
  end

  it "does not record resumes without a pause" do
    karafka.produce({ "resume" => true }.to_json)

    consumer.consume

    expect(karafka.pauses).to be_empty
    expect(karafka.resumes).to be_empty
  end

  it "records one resume per pause" do
    3.times { karafka.produce({ "resume_twice" => true }.to_json) }

    consumer.consume

    expect(karafka.resumes).to eq([{ topic: "pausing_topic", partition: 0 }])
    expect(pause_tracker).not_to be_paused
  end
end
