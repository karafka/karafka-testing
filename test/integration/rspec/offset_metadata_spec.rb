# frozen_string_literal: true

require_relative "../rspec_helper"
require "open3"
require "rbconfig"

RSpec.describe "Pro offset metadata" do
  it "can be read, set and asserted in specs" do
    skip "needs KARAFKA_PRO_LICENSE_TOKEN" unless ENV.key?("KARAFKA_PRO_LICENSE_TOKEN")

    script = File.expand_path("../rspec_pro/offset_metadata_spec.rb", __dir__)
    output, status = Open3.capture2e(
      RbConfig.ruby, "-Ilib", Gem.bin_path("rspec-core", "rspec"), script
    )

    expect(status).to be_success, output
    expect(output).to match(/4 examples, 0 failures/)
  end
end
