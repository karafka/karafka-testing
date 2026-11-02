# frozen_string_literal: true

require_relative "../rspec_helper"
require "open3"
require "rbconfig"

RSpec.describe "RSpec helpers with Mocha" do
  it "work and leave no producer client stub behind" do
    script = File.expand_path("../rspec_with_mocha/helpers_spec.rb", __dir__)
    output, status = Open3.capture2e(
      RbConfig.ruby, "-Ilib", Gem.bin_path("rspec-core", "rspec"), script
    )

    expect(status).to be_success, output
    expect(output).to match(/2 examples, 0 failures/)
  end
end
