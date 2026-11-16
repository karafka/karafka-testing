# frozen_string_literal: true

require_relative "../minitest_helper"
require "open3"
require "rbconfig"

class MinitestOffsetMetadataTest < Minitest::Test
  def test_pro_offset_metadata_can_be_read_set_and_asserted
    skip "needs KARAFKA_PRO_LICENSE_TOKEN" if ENV.fetch("KARAFKA_PRO_LICENSE_TOKEN", "").empty?

    script = File.expand_path("../minitest_pro/offset_metadata_test.rb", __dir__)
    output, status = Open3.capture2e(RbConfig.ruby, "-Ilib", script)

    assert_predicate status, :success?, output
    assert_match(/6 runs, \d+ assertions, 0 failures, 0 errors/, output)
  end
end
