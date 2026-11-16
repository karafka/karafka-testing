# frozen_string_literal: true

module Karafka
  module Testing
    # Reads the offset metadata from the spec client. In a real run the Pro offset metadata
    # fetcher reads it from Kafka through a registered client, which does not exist in specs.
    module SpecOffsetMetadata
      # @param cache [Boolean] ignored, as the spec client holds the metadata in memory
      # @return [Object, false] deserialized offset metadata or false if the partition was revoked
      def offset_metadata(cache: true)
        return false if revoked?

        topic.offset_metadata.deserializer.call(client.offset_metadata)
      end

      alias_method :committed_offset_metadata, :offset_metadata
    end
  end
end
