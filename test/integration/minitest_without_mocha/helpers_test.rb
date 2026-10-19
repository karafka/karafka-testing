# frozen_string_literal: true

# Runs the Minitest helpers the way the docs install them: `karafka-testing` and `minitest`,
# without Mocha. Run as a separate process by `test/integration/minitest/without_mocha_test.rb`,
# because the other Minitest integration tests load Mocha.

require "karafka"

Dir["#{File.expand_path("../support", __dir__)}/**/*.rb"].sort.each { |f| require f }

require "minitest/autorun"
require "karafka/testing/minitest/helpers"

abort("Mocha must not be loaded in this test") if Object.const_defined?("Mocha", false)

# The helper has to remove its producer client stub after every test
Minitest.after_run do
  if Karafka.producer.singleton_class.method_defined?(:client, false)
    warn "Karafka.producer.client is still stubbed after the tests"
    exit!(1)
  end
end

class WithoutMochaTest < Minitest::Test
  include Karafka::Testing::Minitest::Helpers

  def setup
    super
    @consumer = @karafka.consumer_for(:other_topic)
  end

  def test_delivers_message_to_consumer
    @karafka.produce('{"msg":"hello"}')

    assert_equal [{ "msg" => "hello" }], @consumer.messages.map(&:payload)
  end

  def test_tracks_messages_produced_with_karafka_producer
    Karafka.producer.produce_sync(topic: "other_topic", payload: '{"standalone":true}')

    assert_equal 1, @karafka.produced_messages.size
    assert_equal '{"standalone":true}', @karafka.produced_messages.first[:payload]
  end
end

describe "Minitest::Spec without Mocha" do
  include Karafka::Testing::Minitest::Helpers

  it "tracks messages produced with Karafka.producer" do
    Karafka.producer.produce_sync(topic: "other_topic", payload: "spec")

    _(@karafka.produced_messages.size).must_equal 1
  end
end
