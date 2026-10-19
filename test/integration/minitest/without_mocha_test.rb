# frozen_string_literal: true

require_relative "../minitest_helper"
require "open3"
require "rbconfig"

class MinitestWithoutMochaTest < Minitest::Test
  def test_helpers_work_without_mocha
    script = File.expand_path("../minitest_without_mocha/helpers_test.rb", __dir__)
    output, status = Open3.capture2e(RbConfig.ruby, "-Ilib", script)

    assert_predicate status, :success?, output
    assert_match(/3 runs, \d+ assertions, 0 failures, 0 errors/, output)
  end
end
