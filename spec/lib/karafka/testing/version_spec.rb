# frozen_string_literal: true

RSpec.describe Karafka::Testing do
  it { expect(described_class::VERSION).not_to be_nil }
  it { expect(described_class::VERSION).to be_a(String) }
  it { expect(described_class::VERSION).to match(/\A\d+\.\d+\.\d+\z/) }
end
