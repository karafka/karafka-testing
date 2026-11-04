# frozen_string_literal: true

# Runs the RSpec helpers with `mock_with :mocha`. Run as a separate process by
# `test/integration/rspec/with_mocha_spec.rb`, because the other RSpec integration specs use
# rspec-mocks.

require "karafka"

Dir["#{File.expand_path("../support", __dir__)}/**/*.rb"].sort.each { |f| require f }

require "karafka/testing/rspec/helpers"

RSpec.configure do |config|
  config.mock_with :mocha

  # `around` runs before the helper's `prepend_before` hook defines the stub
  config.around do |example|
    StubLeaks.check(example.description)
    example.run
  end

  config.after(:suite) { StubLeaks.verify! }
end

RSpec.describe "RSpec helpers with Mocha" do
  include Karafka::Testing::RSpec::Helpers

  subject(:consumer) { karafka.consumer_for(:other_topic) }

  before { consumer }

  it "delivers a message to the consumer" do
    karafka.produce("one")

    expect(consumer.messages.map(&:raw_payload)).to eq(["one"])
  end

  it "keeps every message with unique offsets when producing from threads" do
    Array.new(8) do |thread|
      Thread.new { 500.times { |i| karafka.produce("#{thread}-#{i}") } }
    end.each(&:join)

    expect(karafka.produced_messages.size).to eq(4_000)
    expect(consumer.messages.map(&:offset).sort).to eq((0...4_000).to_a)
  end
end
