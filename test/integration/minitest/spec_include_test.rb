# frozen_string_literal: true

require_relative "../minitest_helper"
require "open3"
require "rbconfig"

class MinitestSpecIncludeTest < Minitest::Test
  def test_helpers_work_when_included_into_minitest_spec
    script = File.expand_path("../minitest_spec_include/helpers_test.rb", __dir__)
    output, status = Open3.capture2e(RbConfig.ruby, "-Ilib", script)

    assert_predicate status, :success?, output
    assert_match(/2 runs, \d+ assertions, 0 failures, 0 errors/, output)
  end
end
