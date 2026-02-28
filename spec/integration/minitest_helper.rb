# frozen_string_literal: true

require "karafka"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

require "minitest/autorun"
require "mocha/minitest"
require "karafka/testing/minitest/helpers"
