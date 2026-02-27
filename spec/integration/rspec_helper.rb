# frozen_string_literal: true

require "karafka"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

require "karafka/testing/rspec/helpers"
