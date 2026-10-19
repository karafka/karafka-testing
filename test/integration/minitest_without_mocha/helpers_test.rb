# frozen_string_literal: true

# Runs the Minitest helpers the way the docs install them: `karafka-testing` and `minitest`,
# without Mocha. Run as a separate process by `test/integration/minitest/without_mocha_test.rb`,
# because the other Minitest integration tests load Mocha.

require "karafka"

Dir["#{File.expand_path("../support", __dir__)}/**/*.rb"].sort.each { |f| require f }

require "minitest/autorun"
require "karafka/testing/minitest/helpers"

abort("Mocha must not be loaded in this test") if Object.const_defined?("Mocha", false)

# The helper has to remove its producer client stub after every test. A stub left by one test
# is seen before the setup of the next one, or at exit after the last one.
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

class KafkaTestBase < Minitest::Test
  include Karafka::Testing::Minitest::Helpers
end

class TeardownWithoutSuperTest < KafkaTestBase
  def teardown
  end

  def test_tracks_messages_produced_with_karafka_producer
    Karafka.producer.produce_sync(topic: "other_topic", payload: "inherited")

    assert_equal 1, @karafka.produced_messages.size
  end
end

# Mimics `ActiveSupport::TestCase`, which registers setup blocks with a class level `setup`
class ClassLevelSetupTestCase < Minitest::Test
  class << self
    def setup(*_filters, &block)
      setup_blocks << block
    end

    def setup_blocks
      @setup_blocks ||= []
    end
  end

  def setup
    super
    self.class.ancestors.grep(Class).reverse_each do |klass|
      next unless klass.respond_to?(:setup_blocks)

      klass.setup_blocks.each { |block| instance_exec(&block) }
    end
  end
end

class ClassLevelSetupTest < ClassLevelSetupTestCase
  include Karafka::Testing::Minitest::Helpers

  def test_tracks_messages_produced_with_karafka_producer
    Karafka.producer.produce_sync(topic: "other_topic", payload: "class level")

    assert_equal 1, @karafka.produced_messages.size
  end
end
