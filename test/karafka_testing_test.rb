# frozen_string_literal: true

describe "karafka-testing" do
  it "loads without error" do
    require "karafka-testing"
  end

  it "defines Karafka::Testing module" do
    assert_equal "constant", defined?(Karafka::Testing)
  end
end
