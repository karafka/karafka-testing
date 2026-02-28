# frozen_string_literal: true

require "test_helper"

class KarafkaTestingVersionTest < Minitest::Test
  def test_version_is_not_nil
    refute_nil Karafka::Testing::VERSION
  end

  def test_version_is_a_string
    assert_kind_of String, Karafka::Testing::VERSION
  end

  def test_version_matches_semver_format
    assert_match(/\A\d+\.\d+\.\d+\z/, Karafka::Testing::VERSION)
  end
end
