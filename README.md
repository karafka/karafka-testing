# Karafka Testing library

[![Build Status](https://github.com/karafka/karafka-testing/workflows/ci/badge.svg)](https://github.com/karafka/karafka-testing/actions?query=workflow%3Aci)
[![Gem Version](https://badge.fury.io/rb/karafka-testing.svg)](http://badge.fury.io/rb/karafka-testing)
[![Join the chat at https://slack.karafka.io](https://raw.githubusercontent.com/karafka/misc/master/slack.svg)](https://slack.karafka.io)

Karafka-Testing is a library that provides RSpec helpers, to make testing of Karafka consumers and producer much easier.

## Installation

Add this gem to your Gemfile in the `test` group:
```ruby
group :test do
  gem 'karafka-testing'
  gem 'rspec'
end
```

and then in your `spec_helper.rb` file:

```ruby
require 'karafka/testing/rspec/helpers'

RSpec.configure do |config|
  config.include Karafka::Testing::RSpec::Helpers
end
```

## Usage

Once included in your RSpec setup, this library will provide you with a special `#karafka` object that contains three methods that you can use within your specs:

- `#consumer_for` - creates a consumer instance for the desired topic. It **needs** to be set as the spec subject.
- `#produce` - "sends" message to the consumer instance.
- `#produced_messages` - contains all the messages "sent" to Kafka during spec execution.

**Note:** Messages sent using the `#produce` method and directly from `Karafka.producer` won't be sent to Kafka. They will be buffered and accessible in a per-spec buffer in case you want to test messages production.

Messages that target the topic built using the `karafka#consumer_for` method will additionally be delivered to the consumer you want to test.

### Testing messages consumption (consumers)

```ruby
RSpec.describe InlineBatchConsumer do
  # This will create a consumer instance with all the settings defined for the given topic
  subject(:consumer) { karafka.consumer_for('inline_batch_data') }

  let(:nr1_value) { rand }
  let(:nr2_value) { rand }
  let(:sum) { nr1_value + nr2_value }

  before do
    # Sends first message to Karafka consumer
    karafka.produce({ 'number' => nr1_value }.to_json)

    # Sends second message to Karafka consumer
    karafka.produce({ 'number' => nr2_value }.to_json, partition: 2)

    allow(Karafka.logger).to receive(:info)
  end

  it 'expects to log a proper message' do
    expect(Karafka.logger).to receive(:info).with("Sum of 2 elements equals to: #{sum}")
    consumer.consume
  end
end
```

If your consumers use `producer` to dispatch messages, you can check its operations as well:

```ruby
RSpec.describe InlineBatchConsumer do
  subject(:consumer) { karafka.consumer_for(:inline_batch_data) }

  before { karafka.produce({ 'number' => 1 }.to_json) }

  it 'expects to dispatch async message to messages topic with value bigger by 1' do
    consumer.consume

    expect(karafka.produced_messages.last.payload).to eq({ number: 2 }.to_json)
  end
end
```

### Testing messages production (producer)

When running RSpec, Karafka will not dispatch messages to Kafka using `Karafka.producer` but will buffer them internally.

This means you can check your application flow, making sure your logic acts as expected:

```ruby
# Example class in which there is a message production
class UsersBuilder
  def create(user_details)
    user = ::User.create!(user_details)

    Karafka.producer.produce_sync(
      topic: 'users_changes',
      payload: { user_id: user.id, type: 'user.created' },
      key: user.id.to_s
    )

    user
  end
end

RSpec.describe InlineBatchConsumer do
  let(:created_user) { UsersBuilder.new.create(user_details) }

  before { created_user }

  it 'expect to dispatch proper message to Kafka after user creation' do
    expect(karafka.produced_messages.size).to eq(1)
    expect(karafka.produced_messages.first[:topic]).to eq('user.created')
    expect(karafka.produced_messages.first[:key]).to eq(created_user.id.to_s)
  end
end

```

## Note on contributions

First, thank you for considering contributing to the Karafka ecosystem! It's people like you that make the open source community such a great community!

Each pull request must pass all the RSpec specs, integration tests and meet our quality requirements.

Fork it, update and wait for the Github Actions results.
