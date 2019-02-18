
module Karafka
  module Testing
    # All the things related to extra functionalities needed to easier spec out
    # Karafka things using RSpec
    module RSpec
      # RSpec helpers module that needs to be included
      module Helpers
        class << self
          def included(base)
            # This is an internal buffer for keeping "to be sent" messages before
            # we run the consume
            base.let(:_karafka_raw_data) { [] }
            # Clear the messages buffer after each spec, so nothing will leak
            # in between them
            base.after { _karafka_raw_data.clear }
          end
        end

        def karafka_consumer_for(requested_topic)
          selected_topic = nil

          App.consumer_groups.each do |consumer_group|
            consumer_group.topics.each do |topic|
              selected_topic = topic if topic.name == requested_topic.to_s
            end
          end

          raise unless selected_topic

          described_class.new(selected_topic)
        end

        def publish_for_karafka(payload, opts = {})
          _karafka_raw_data << Karafka::Params::Params
            .new
            .merge!(
              'deserializer' => consumer.topic.deserializer,
              'create_time' => Time.now,
              'headers' => {},
              'is_control_record' => false,
              'key' => nil,
              'offset' => 0,
              'partition' => 0,
              'receive_time' => Time.now,
              'topic' => consumer.topic.name
            )
            .merge!('payload' => payload)
            .merge!(opts)

          consumer.params_batch = Karafka::Params::ParamsBatch
                                  .new(_karafka_raw_data)
        end
      end
    end
  end
end
