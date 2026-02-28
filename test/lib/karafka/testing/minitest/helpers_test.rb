# frozen_string_literal: true

class KarafkaTestingMinitestHelpersTest < Minitest::Test
  def test_maps_raw_key_to_key
    mappings = Karafka::Testing::Minitest::Helpers.const_get(:METADATA_DISPATCH_MAPPINGS)

    assert_equal :key, mappings[:raw_key]
  end

  def test_maps_raw_headers_to_headers
    mappings = Karafka::Testing::Minitest::Helpers.const_get(:METADATA_DISPATCH_MAPPINGS)

    assert_equal :headers, mappings[:raw_headers]
  end

  def test_is_a_module
    assert_kind_of Module, Karafka::Testing::Minitest::Helpers
  end
end
