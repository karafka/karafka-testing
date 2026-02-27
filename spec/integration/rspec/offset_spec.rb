# frozen_string_literal: true

require_relative "../rspec_helper"

RSpec.describe "offset handling" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  it "auto-increments offsets starting from 0" do
    karafka.produce('{"n":0}')
    karafka.produce('{"n":1}')
    karafka.produce('{"n":2}')

    offsets = consumer.messages.map(&:offset)
    expect(offsets).to eq([0, 1, 2])
  end

  it "uses the provided custom offset" do
    karafka.produce('{"x":1}', offset: 1337)
    expect(consumer.messages.first.offset).to eq(1337)
  end

  it "resumes auto-increment after a custom offset" do
    karafka.produce('{"n":0}')
    karafka.produce('{"n":1}', offset: 100)
    karafka.produce('{"n":2}')

    offsets = consumer.messages.map(&:offset)
    expect(offsets).to eq([0, 100, 2])
  end

  it "handles offset: 0 explicitly" do
    karafka.produce('{"first":true}', offset: 0)
    expect(consumer.messages.first.offset).to eq(0)
  end

  it "handles multiple custom offsets in sequence" do
    karafka.produce('{"n":0}', offset: 10)
    karafka.produce('{"n":1}', offset: 20)
    karafka.produce('{"n":2}', offset: 30)

    offsets = consumer.messages.map(&:offset)
    expect(offsets).to eq([10, 20, 30])
  end
end
