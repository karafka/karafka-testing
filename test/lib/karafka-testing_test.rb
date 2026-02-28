# frozen_string_literal: true

class KarafkaTestingLoadTest < Minitest::Test
  def test_loads_without_error
    require "karafka-testing"
  end

  def test_defines_karafka_testing_module
    assert_equal "constant", defined?(Karafka::Testing)
  end
end
