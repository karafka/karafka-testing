# frozen_string_literal: true

require "test_helper"

describe Karafka::Testing do
  describe ".ensure_karafka_loaded!" do
    context "when Karafka::App is defined" do
      before do
        stub_const("Karafka::App", Class.new)
      end

      it "does not raise an error" do
        Karafka::Testing.ensure_karafka_loaded!
      end
    end

    context "when Karafka::App is not defined" do
      before do
        Karafka.stubs(:const_defined?).with("App", false).returns(false)
      end

      it "raises KarafkaNotLoadedError" do
        assert_raises(Karafka::Testing::Errors::KarafkaNotLoadedError) do
          Karafka::Testing.ensure_karafka_loaded!
        end
      end
    end
  end

  describe ".ensure_karafka_initialized!" do
    context "when Karafka is fully initialized" do
      before do
        stub_const("Karafka::App", Class.new {
          def self.initializing?
            false
          end
        })
      end

      it "does not raise an error" do
        Karafka::Testing.ensure_karafka_initialized!
      end
    end

    context "when Karafka is still initializing" do
      before do
        stub_const("Karafka::App", Class.new {
          def self.initializing?
            true
          end
        })
      end

      it "raises KarafkaNotInitializedError" do
        assert_raises(Karafka::Testing::Errors::KarafkaNotInitializedError) do
          Karafka::Testing.ensure_karafka_initialized!
        end
      end
    end

    context "when Karafka is not loaded" do
      before do
        Karafka.stubs(:const_defined?).with("App", false).returns(false)
      end

      it "raises KarafkaNotLoadedError" do
        assert_raises(Karafka::Testing::Errors::KarafkaNotLoadedError) do
          Karafka::Testing.ensure_karafka_initialized!
        end
      end
    end
  end
end
