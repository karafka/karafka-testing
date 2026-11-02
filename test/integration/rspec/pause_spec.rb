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
end
