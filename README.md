# Karafka Testing library

**Note**: Documentation presented below works with not yet released Karafka `2.0`.

Please refer to [this](https://github.com/karafka/testing/tree/1.4) branch and its documentation for details about usage with Karafka `1.4`.

[![Build Status](https://github.com/karafka/testing/workflows/ci/badge.svg)](https://github.com/karafka/testing/actions?query=workflow%3Aci)
[![Gem Version](https://badge.fury.io/rb/karafka-testing.svg)](http://badge.fury.io/rb/karafka-testing)
[![Join the chat at https://slack.karafka.io](https://raw.githubusercontent.com/karafka/misc/master/slack.svg)](https://slack.karafka.io)

Karafka-Testing is a library that provides RSpec helpers, to make testing of Karafka consumers much easier.

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

Once included into your RSpec setup, this library will provide you with a special object `#karafka` that includes two methods that you can use with your specs:

- `#consumer_for` - creates a consumer instance for the desired topic. It **needs** to be set as the spec subject.
- `#publish` - "sends" message to the consumer instance.

**Note:** Messages sent using the `#publish` method won't be sent to Kafka. They will be "virtually" delegated to the created consumer instance so your specs can run without Kafka setup.

```ruby
RSpec.describe InlineBatchConsumer do
  # This will create a consumer instance with all the settings defined for the given topic
  subject(:consumer) { karafka.consumer_for(:inline_batch_data) }

  let(:nr1_value) { rand }
  let(:nr2_value) { rand }
  let(:sum) { nr1_value + nr2_value }

  before do
    # Sends first message to Karafka consumer
    karafka.publish({ 'number' => nr1_value }.to_json)
    # Sends second message to Karafka consumer
    karafka.publish({ 'number' => nr2_value }.to_json, partition: 2)
    allow(Karafka.logger).to receive(:info)
  end

  it 'expects to log a proper message' do
    expect(Karafka.logger).to receive(:info).with("Sum of 2 elements equals to: #{sum}")
    consumer.consume
  end
end
```

## Note on contributions

First, thank you for considering contributing to the Karafka ecosystem! It's people like you that make the open source community such a great community!

Each pull request must pass all the RSpec specs, integration tests and meet our quality requirements.

Fork it, update and wait for the Github Actions results.
