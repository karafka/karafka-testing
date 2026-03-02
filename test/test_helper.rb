# frozen_string_literal: true

Warning[:performance] = true if RUBY_VERSION >= "3.3"
Warning[:deprecated] = true
$VERBOSE = true

require "warning"

Warning.process do |warning|
  next unless warning.include?(Dir.pwd)
  next if warning.include?("vendor/bundle")
  next if warning.include?("$CHILD_STATUS")

  raise "Warning in your code: #{warning}"
end

require "ostruct"

coverage = !ENV.key?("GITHUB_WORKFLOW")
coverage = true if ENV["GITHUB_COVERAGE"] == "true"

if coverage
  require "simplecov"

  SimpleCov.start do
    add_filter "/test/"
    add_filter "/vendor/"
    add_filter "/gems/"
    add_filter "/.bundle/"
    add_filter "/doc/"
    add_filter "/config/"
    # Helpers require full Karafka integration to test properly
    add_filter "/lib/karafka/testing/rspec/helpers.rb"
    add_filter "/lib/karafka/testing/minitest/helpers.rb"

    merge_timeout 600
    minimum_coverage 100
    enable_coverage :branch
  end
end

require "minitest/autorun"
require "mocha/minitest"

require "waterdrop"
require "karafka-testing"

Dir[File.join(__dir__, "../lib/karafka/testing/**/*.rb")].each { |f| require f }

class Minitest::Spec
  class << self
    alias_method :context, :describe
  end

  # Helper to temporarily stub a constant, creating intermediate modules if needed
  def stub_const(name, value)
    parts = name.split("::")
    const_name = parts.pop
    created_modules = []

    mod = parts.reduce(Object) do |m, c|
      unless m.const_defined?(c, false)
        new_mod = Module.new
        m.const_set(c, new_mod)
        created_modules << [m, c]
      end
      m.const_get(c, false)
    end

    old_value = if mod.const_defined?(const_name, false)
      mod.const_get(const_name, false)
    else
      :__undefined__
    end
    mod.send(:remove_const, const_name) if mod.const_defined?(const_name, false)
    mod.const_set(const_name, value)

    @_stub_const_restorers ||= []
    @_stub_const_restorers << -> {
      mod.send(:remove_const, const_name) if mod.const_defined?(const_name, false)
      mod.const_set(const_name, old_value) unless old_value == :__undefined__
      created_modules.reverse_each do |parent, child|
        parent.send(:remove_const, child) if parent.const_defined?(child, false)
      end
    }
  end

  def teardown
    super
  ensure
    if @_stub_const_restorers
      @_stub_const_restorers.reverse_each(&:call)
      @_stub_const_restorers = nil
    end
  end
end
