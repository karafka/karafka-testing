# frozen_string_literal: true

Warning[:performance] = true if RUBY_VERSION >= '3.3'
Warning[:deprecated] = true
$VERBOSE = true

require 'warning'

Warning.process do |warning|
  next unless warning.include?(Dir.pwd)
  next if warning.include?('vendor/bundle')
  next if warning.include?('$CHILD_STATUS')

  raise "Warning in your code: #{warning}"
end

require 'ostruct'

coverage = !ENV.key?('GITHUB_WORKFLOW')
coverage = true if ENV['GITHUB_COVERAGE'] == 'true'

if coverage
  require 'simplecov'

  SimpleCov.start do
    add_filter '/spec/'
    add_filter '/vendor/'
    add_filter '/gems/'
    add_filter '/.bundle/'
    add_filter '/doc/'
    add_filter '/config/'

    merge_timeout 600
    minimum_coverage 100
    enable_coverage :branch
  end
end

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.order = :random

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
end

require 'karafka/core/helpers/rspec_locator'
RSpec.extend Karafka::Core::Helpers::RSpecLocator.new(__FILE__)

require 'waterdrop'
require 'karafka-testing'
require 'karafka/testing/errors'
require 'karafka/testing/spec_consumer_client'
require 'karafka/testing/spec_producer_client'
require 'karafka/testing/rspec/proxy'
require 'karafka/testing/minitest/proxy'
