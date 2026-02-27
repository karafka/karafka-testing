# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "transactional testing" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  before do
    allow(Karafka.producer).to receive(:transactional?).and_return(true)
  end

  it "retains messages after a committed transaction" do
    Karafka.producer.transaction do
      karafka.produce('{"txn":"committed"}')
    end

    expect(karafka.produced_messages.size).to eq(1)
    expect(karafka.produced_messages.first[:payload]).to eq('{"txn":"committed"}')
    expect(consumer.messages.size).to eq(1)
  end

  it "discards messages after an aborted transaction" do
    Karafka.producer.transaction do
      karafka.produce('{"txn":"aborted"}')
      raise WaterDrop::Errors::AbortTransaction
    end

    expect(karafka.produced_messages).to be_empty
  end
end
