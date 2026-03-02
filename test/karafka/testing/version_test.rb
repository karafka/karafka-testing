# frozen_string_literal: true

require "test_helper"

describe Karafka::Testing do
  it "has a version" do
    refute_nil Karafka::Testing::VERSION
  end

  it "version is a string" do
    assert_kind_of String, Karafka::Testing::VERSION
  end

  it "version matches semver format" do
    assert_match(/\A\d+\.\d+\.\d+\z/, Karafka::Testing::VERSION)
  end
end
