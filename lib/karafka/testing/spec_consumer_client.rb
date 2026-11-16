# frozen_string_literal: true

module Karafka
  module Testing
    # A spec client that takes over client delegated methods from the consumers
    # For specs we do not mark anything as consumed, nor do we really send heartbeats.
    # Those things are tested in the framework itself
    class SpecConsumerClient
      # @return [Array<Hash>] pauses requested on this client, each with the `topic`,
      #   `partition`, `offset` and `timeout`
      attr_reader :pauses

      # @return [Array<Hash>] resumes requested on this client, each with the `topic` and
      #   `partition`
      attr_reader :resumes

      # @return [Array<Hash>] messages marked as consumed on this client, each with the `topic`,
      #   `partition`, `offset` and offset `metadata`
      attr_reader :marks

      # @return [String, nil] raw offset metadata the consumers read as committed
      attr_accessor :offset_metadata

      # Builds a client with no pauses, resumes or marks recorded and no offset metadata
      def initialize
        @pauses = []
        @resumes = []
        @marks = []
        @offset_metadata = nil
      end

      %i[
        commit_offsets
        commit_offsets!
        seek
        consumer_group_metadata_pointer
      ].each do |caught_delegator|
        define_method(caught_delegator) { |*| true }
      end

      # Records the mark instead of storing the offset
      #
      # @param message [Karafka::Messages::Message] message marked as consumed
      # @param metadata [String, nil] offset metadata or nil if none
      # @return [true]
      def mark_as_consumed(message, metadata = nil)
        @marks << {
          topic: message.topic,
          partition: message.partition,
          offset: message.offset,
          metadata: metadata
        }
        true
      end

      alias_method :mark_as_consumed!, :mark_as_consumed

      # Records the pause instead of pausing the partition
      #
      # @param topic_name [String] topic name
      # @param partition [Integer] partition
      # @param offset [Integer, nil] offset to continue from or nil to keep the current position
      # @param timeout [Integer] pause time in milliseconds
      # @return [true]
      def pause(topic_name, partition, offset = nil, timeout = 0)
        @pauses << { topic: topic_name, partition: partition, offset: offset, timeout: timeout }
        true
      end

      # Records the resume instead of resuming the partition
      #
      # @param topic_name [String] topic name
      # @param partition [Integer] partition
      # @return [true]
      def resume(topic_name, partition)
        @resumes << { topic: topic_name, partition: partition }
        true
      end

      # @return [Boolean] assignments are never lost for specs
      def assignment_lost?
        false
      end
    end
  end
end
