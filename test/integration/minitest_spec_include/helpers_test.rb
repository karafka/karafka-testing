# frozen_string_literal: true

# Includes the Minitest helpers into `Minitest::Spec` itself, so every spec gets them. Run as a
# separate process by `test/integration/minitest/spec_include_test.rb`, because the include
# changes all the specs of the process.

require "karafka"

Dir["#{File.expand_path("../support", __dir__)}/**/*.rb"].sort.each { |f| require f }

require "minitest/autorun"
require "karafka/testing/minitest/helpers"

Minitest::Spec.include(Karafka::Testing::Minitest::Helpers)

Minitest::Test.prepend(
  Module.new do
    def before_setup
      StubLeaks.check(name)
      super
    end
  end
)

Minitest.after_run { StubLeaks.verify! }

describe "Minitest::Spec with the helpers included" do
  before do
    @consumer = @karafka.consumer_for(:other_topic)
  end

  it "delivers messages to the consumer" do
    @karafka.produce('{"msg":"hello"}')

    _(@consumer.messages.map(&:payload)).must_equal [{ "msg" => "hello" }]
  end

  it "tracks messages produced with Karafka.producer" do
    Karafka.producer.produce_sync(topic: "other_topic", payload: "spec")

    _(@karafka.produced_messages.size).must_equal 1
  end
end
