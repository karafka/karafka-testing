# frozen_string_literal: true

module Karafka
  module Testing
    # Common helper methods that are shared in between RSpec and Minitest
    module Helpers
      class << self
        # Finds all the routing topics matching requested topic within all topics or within
        # provided consumer group based on name
        #
        # @param topic_name [String] requested topic name
        # @param requested_consumer_group [String] requested consumer group or nil to look in all
        # @return [Array<Karafka::Routing::Topic>] all matching topics
        #
        # @note Since we run the lookup on subscription groups, the search will automatically
        #   expand with matching patterns
        def karafka_consumer_find_candidate_topics(topic_name, requested_consumer_group)
          subscription_groups = karafka_consumer_find_subscription_groups(requested_consumer_group)

          candidate_topics = []

          subscription_groups.each do |group|
            topic = group.topics.find(topic_name.to_s)

            next unless topic

            candidate_topics << topic
          rescue Karafka::Errors::TopicNotFoundError
            # Skip groups that don't have the requested topic
            next
          end

          # Remove duplicate topics from multiplexed subscriptions
          # (Multiplexed subscriptions share the same name, and during testing
          # there's no parallel execution anyway, so we only need the first one)
          candidate_topics.uniq { |topic| topic.subscription_group.name }
        end

        # Builds a coordinator for given topic partition, as a consumer gets in a real run
        #
        # @param topic [Karafka::Routing::Topic] topic of the consumer
        # @param partition [Integer] partition the consumer works on
        # @return [Karafka::Processing::ConsumerGroups::Coordinator] coordinator for the partition
        def karafka_build_coordinator(topic, partition)
          coordinator = Karafka::Processing::CoordinatorsBuffer
            .new(Karafka::Routing::Topics.new([topic]))
            .find_or_create(topic.name, partition)

          coordinator.seek_offset = 0
          coordinator
        end

        # Finds subscription groups from the requested consumer group or selects all if no
        # consumer group specified
        # @param requested_consumer_group [String] requested consumer group or nil to look in all
        # @return [Array<Karafka::Routing::SubscriptionGroup>] requested subscription groups
        def karafka_consumer_find_subscription_groups(requested_consumer_group)
          if requested_consumer_group && !requested_consumer_group.empty?
            ::Karafka::App
              .subscription_groups
              # Find matching consumer group
              .find { |cg, _sgs| cg.name == requested_consumer_group.to_s }
              # Raise error if not found
              .then do |cg|
                cg || raise(Errors::ConsumerGroupNotFoundError, requested_consumer_group)
                # Since lookup was on a hash, get the value, that is subscription groups
                cg.last
              end
          else
            ::Karafka::App
              .subscription_groups
              .values
              .flatten
          end
        end
      end
    end
  end
end
