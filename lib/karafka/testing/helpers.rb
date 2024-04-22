# frozen_string_literal: true

module Karafka
  module Testing
    # Common helper methods that are shared in between RSpec and Minitest
    module Helpers
      class << self
        # Finds all the routing topics matching requested topic within all topics or within
        # provided consumer group based on name
        #
        # @param requested_topic [String] requested topic name
        # @param requested_consumer_group [String] requested consumer group or nil to look in all
        # @return [Array<Karafka::Routing::Topic>] all matching topics
        #
        # @note Since we run the lookup on subscription groups, the search will automatically
        #   expand with matching patterns
        def karafka_consumer_find_candidate_topics(requested_topic, requested_consumer_group)
          karafka_consumer_find_subscription_groups(requested_consumer_group)
            # multiplexed subscriptions of the same origin share name, thus we can reduced
            # multiplexing to the first one as during testing, there is no multiplexing parallel
            # execution anyhow
            .uniq(&:name)
            .map(&:topics)
            .filter_map do |topics|
              topics.find(requested_topic.to_s)
            rescue Karafka::Errors::TopicNotFoundError
              nil
            end
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
              .tap { |cg| cg || raise(Errors::ConsumerGroupNotFound, requested_consumer_group) }
              # Since lookup was on a hash, get the value, that is subscription groups
              .last
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
