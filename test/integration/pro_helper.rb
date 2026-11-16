# frozen_string_literal: true

# Loads Karafka with Pro for the scenarios run as separate processes. Needs a real license in
# `KARAFKA_PRO_LICENSE_TOKEN`.

module Karafka
  module License
    class << self
      def token
        ENV.fetch("KARAFKA_PRO_LICENSE_TOKEN")
      end

      def version
        ENV.fetch("KARAFKA_PRO_LICENSE_VERSION", "1")
      end
    end
  end
end

require "karafka"
require "json"

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each { |f| require f }

abort("Karafka Pro must be loaded") unless Karafka.pro?

class OffsetMetadataConsumer < Karafka::BaseConsumer
  attr_reader :restored_state

  def consume
    @restored_state = offset_metadata

    count = (@restored_state["count"] || 0) + messages.size
    mark_as_consumed(messages.first, { "first" => true }.to_json)
    store_offset_metadata({ "count" => count }.to_json)
    mark_as_consumed(messages.last)
  end
end

Karafka::App.routes.draw do
  topic :offset_metadata_topic do
    consumer OffsetMetadataConsumer
    offset_metadata(deserializer: ->(raw) { raw ? JSON.parse(raw) : {} })
  end
end
