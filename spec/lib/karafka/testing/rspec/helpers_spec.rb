# frozen_string_literal: true

RSpec.describe Karafka::Testing::RSpec::Helpers do
  describe 'METADATA_DISPATCH_MAPPINGS' do
    subject(:mappings) { described_class.const_get(:METADATA_DISPATCH_MAPPINGS) }

    it 'maps raw_key to key' do
      expect(mappings[:raw_key]).to eq(:key)
    end

    it 'maps raw_headers to headers' do
      expect(mappings[:raw_headers]).to eq(:headers)
    end
  end

  describe '.included' do
    it 'is a module that can be included' do
      expect(described_class).to be_a(Module)
    end
  end
end
