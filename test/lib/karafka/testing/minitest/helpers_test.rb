# frozen_string_literal: true

describe_current do
  describe "METADATA_DISPATCH_MAPPINGS" do
    let(:mappings) { Karafka::Testing::Minitest::Helpers.const_get(:METADATA_DISPATCH_MAPPINGS) }

    it "maps raw_key to key" do
      assert_equal :key, mappings[:raw_key]
    end

    it "maps raw_headers to headers" do
      assert_equal :headers, mappings[:raw_headers]
    end
  end

  describe ".included" do
    it "is a module that can be included" do
      assert_kind_of Module, Karafka::Testing::Minitest::Helpers
    end
  end
end
