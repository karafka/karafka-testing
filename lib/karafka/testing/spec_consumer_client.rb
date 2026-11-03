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

      # Builds a client with no pauses or resumes recorded
      def initialize
        @pauses = []
        @resumes = []
      end

      %i[
        mark_as_consumed
        mark_as_consumed!
        commit_offsets
        commit_offsets!
        seek
        consumer_group_metadata_pointer
      ].each do |caught_delegator|
        define_method(caught_delegator) { |*| true }
      end

      # Records the pause instead of pausing the partition
      #
      # @param topic [String] topic name
      # @param partition [Integer] partition
      # @param offset [Integer, nil] offset to continue from or nil to keep the current position
      # @param timeout [Integer] pause time in milliseconds
      # @return [true]
      def pause(topic, partition, offset = nil, timeout = 0)
        @pauses << { topic: topic, partition: partition, offset: offset, timeout: timeout }
        true
      end

      # Records the resume instead of resuming the partition
      #
      # @param topic [String] topic name
      # @param partition [Integer] partition
      # @return [true]
      def resume(topic, partition)
        @resumes << { topic: topic, partition: partition }
        true
      end

      # @return [Boolean] assignments are never lost for specs
      def assignment_lost?
        false
      end
    end
  end
end
