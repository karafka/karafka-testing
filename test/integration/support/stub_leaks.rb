# frozen_string_literal: true

# The helpers have to remove their producer client stub after every test. A stub left by one
# test is seen before the next one starts, or after the last one.
module StubLeaks
  class << self
    # @param name [String] the test about to run, or where the check runs
    def check(name)
      leaks << name if Karafka.producer.singleton_class.method_defined?(:client, false)
    end

    # Fails the process when a stub was left behind
    def verify!
      check("after the last test")

      return if leaks.empty?

      warn "Karafka.producer.client was still stubbed before: #{leaks.join(", ")}"
      exit 1
    end

    private

    def leaks
      @leaks ||= []
    end
  end
end
