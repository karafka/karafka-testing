# frozen_string_literal: true

require "karafka/testing/pro/spec_offset_metadata"

module Karafka
  module Testing
    # Spec replacements for Pro consumer features that need a running Kafka client
    module Pro
      # Prepends the Pro spec extensions to consumers built in specs
      module Injector
        # Pro spec extensions with the topic predicate that enables each of them
        EXTENSIONS = {
          SpecOffsetMetadata => :offset_metadata?
        }.freeze

        private_constant :EXTENSIONS

        class << self
          # Prepends the extensions of the features the topic uses when Pro is loaded
          #
          # @param consumer [Karafka::BaseConsumer] consumer built for specs
          # @param topic [Karafka::Routing::Topic] topic of the consumer
          def inject(consumer, topic)
            return unless Karafka.pro?

            EXTENSIONS.each do |extension, enabled|
              next unless topic.public_send(enabled)

              consumer.singleton_class.prepend(extension)
            end
          end
        end
      end
    end
  end
end
