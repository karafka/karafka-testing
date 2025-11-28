# frozen_string_literal: true

RSpec.describe_current do
  describe '.ensure_karafka_loaded!' do
    context 'when Karafka::App is defined' do
      before do
        stub_const('Karafka::App', Class.new)
      end

      it 'does not raise an error' do
        expect { described_class.ensure_karafka_loaded! }.not_to raise_error
      end
    end

    context 'when Karafka::App is not defined' do
      before do
        allow(Karafka).to receive(:const_defined?).with('App', false).and_return(false)
      end

      it 'raises KarafkaNotLoadedError' do
        expect { described_class.ensure_karafka_loaded! }
          .to raise_error(Karafka::Testing::Errors::KarafkaNotLoadedError)
      end
    end
  end

  describe '.ensure_karafka_initialized!' do
    context 'when Karafka is fully initialized' do
      before do
        stub_const('Karafka::App', Class.new do
          def self.initializing?
            false
          end
        end)
      end

      it 'does not raise an error' do
        expect { described_class.ensure_karafka_initialized! }.not_to raise_error
      end
    end

    context 'when Karafka is still initializing' do
      before do
        stub_const('Karafka::App', Class.new do
          def self.initializing?
            true
          end
        end)
      end

      it 'raises KarafkaNotInitializedError' do
        expect { described_class.ensure_karafka_initialized! }
          .to raise_error(Karafka::Testing::Errors::KarafkaNotInitializedError)
      end
    end

    context 'when Karafka is not loaded' do
      before do
        allow(Karafka).to receive(:const_defined?).with('App', false).and_return(false)
      end

      it 'raises KarafkaNotLoadedError' do
        expect { described_class.ensure_karafka_initialized! }
          .to raise_error(Karafka::Testing::Errors::KarafkaNotLoadedError)
      end
    end
  end
end
