# frozen_string_literal: true

RSpec.describe "karafka-testing" do
  it "loads without error" do
    expect { require "karafka-testing" }.not_to raise_error
  end

  it "defines Karafka::Testing module" do
    expect(defined?(Karafka::Testing)).to eq("constant")
  end
end
