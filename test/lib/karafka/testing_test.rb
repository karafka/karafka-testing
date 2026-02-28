# frozen_string_literal: true

class KarafkaTestingEnsureLoadedTest < Minitest::Test
  def test_does_not_raise_when_karafka_app_defined
    stub_karafka_app

    Karafka::Testing.ensure_karafka_loaded!
  ensure
    remove_karafka_app_stub
  end

  def test_raises_karafka_not_loaded_error_when_app_not_defined
    Karafka.stubs(:const_defined?).with("App", false).returns(false)

    assert_raises(Karafka::Testing::Errors::KarafkaNotLoadedError) do
      Karafka::Testing.ensure_karafka_loaded!
    end
  end

  private

  def stub_karafka_app
    @original_app = Karafka.const_defined?(:App, false) ? Karafka::App : nil
    Karafka.const_set(:App, Class.new) unless @original_app
  end

  def remove_karafka_app_stub
    return if @original_app

    Karafka.send(:remove_const, :App) if Karafka.const_defined?(:App, false)
  end
end

class KarafkaTestingEnsureInitializedTest < Minitest::Test
  def test_does_not_raise_when_fully_initialized
    app = Class.new do
      def self.initializing?
        false
      end
    end

    with_karafka_app(app) do
      Karafka::Testing.ensure_karafka_initialized!
    end
  end

  def test_raises_when_still_initializing
    app = Class.new do
      def self.initializing?
        true
      end
    end

    with_karafka_app(app) do
      assert_raises(Karafka::Testing::Errors::KarafkaNotInitializedError) do
        Karafka::Testing.ensure_karafka_initialized!
      end
    end
  end

  def test_raises_karafka_not_loaded_error_when_app_not_defined
    Karafka.stubs(:const_defined?).with("App", false).returns(false)

    assert_raises(Karafka::Testing::Errors::KarafkaNotLoadedError) do
      Karafka::Testing.ensure_karafka_initialized!
    end
  end

  private

  def with_karafka_app(app)
    original = Karafka.const_defined?(:App, false) ? Karafka::App : nil
    Karafka.send(:remove_const, :App) if original
    Karafka.const_set(:App, app)
    yield
  ensure
    Karafka.send(:remove_const, :App) if Karafka.const_defined?(:App, false)
    Karafka.const_set(:App, original) if original
  end
end
