# frozen_string_literal: true

# Includes the Minitest helpers into `Minitest::Spec` itself, so every spec gets them. Run as a
# separate process by `test/integration/minitest/spec_include_test.rb`, because the include
# changes all the specs of the process.

require "karafka"

Dir["#{File.expand_path("../support", __dir__)}/**/*.rb"].sort.each { |f| require f }

require "minitest/autorun"
require "karafka/testing/minitest/helpers"

Minitest::Spec.include(Karafka::Testing::Minitest::Helpers)

STUB_LEAKS = []

def stub_leaked?
  Karafka.producer.singleton_class.method_defined?(:client, false)
end

Minitest::Test.prepend(
  Module.new do
    def before_setup
      STUB_LEAKS << name if stub_leaked?
      super
    end
  end
)

Minitest.after_run do
  STUB_LEAKS << "after the last test" if stub_leaked?

  unless STUB_LEAKS.empty?
    warn "Karafka.producer.client was still stubbed before: #{STUB_LEAKS.join(", ")}"
    exit!(1)
  end
end

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
