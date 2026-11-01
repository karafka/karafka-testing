# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "producing from many threads" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  let(:threads) { 8 }
  let(:per_thread) { 500 }
  let(:total) { threads * per_thread }

  before { consumer }

  it "keeps every message with unique offsets" do
    Array.new(threads) do |thread|
      Thread.new { per_thread.times { |i| karafka.produce("#{thread}-#{i}") } }
    end.each(&:join)

    expect(karafka.produced_messages.size).to eq(total)
    expect(karafka.consumer_messages.size).to eq(total)
    expect(consumer.messages.map(&:offset).sort).to eq((0...total).to_a)
  end

  it "keeps every message produced to another topic" do
    Array.new(threads) do |thread|
      Thread.new do
        per_thread.times do |i|
          Karafka.producer.produce_sync(topic: "test_topic", payload: "#{thread}-#{i}")
        end
      end
    end.each(&:join)

    expect(karafka.produced_messages.size).to eq(total)
    expect(karafka.consumer_messages).to be_empty
  end
end
