# frozen_string_literal: true

# Main Karafka module
module Karafka
  # Testing lib module
  module Testing
    class << self
      # Makes sure, that we do not use the testing stubs, etc when Karafka app is not loaded
      #
      # You should never use karafka-testing primitives when framework is not loaded because
      # testing lib stubs certain pieces of Karafka that need to be initialized.
      def ensure_karafka_loaded!
        return if ::Karafka.const_defined?('App', false)

        raise(
          Karafka::Testing::Errors::KarafkaNotLoadedError,
          'Make sure to load Karafka framework prior to usage of the testing components.'
        )
      end

      # If you do not initialize Karafka always within your specs, do not include/use this lib
      # in places where Karafka would not be loaded.
      def ensure_karafka_initialized!
        ensure_karafka_loaded!

        return unless Karafka::App.initializing?

        raise(
          Karafka::Testing::Errors::KarafkaNotInitializedError,
          'Make sure to initialize Karafka framework prior to usage of the testing components.'
        )
      end
    end
  end
end
