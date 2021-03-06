# Karafka Testing library

[![Build Status](https://github.com/karafka/testing/workflows/ci/badge.svg)](https://github.com/karafka/testing/actions?query=workflow%3Aci)
[![Gem Version](https://badge.fury.io/rb/karafka-testing.svg)](http://badge.fury.io/rb/karafka-testing)
[![Join the chat at https://gitter.im/karafka/karafka](https://badges.gitter.im/karafka/karafka.svg)](https://gitter.im/karafka/karafka)

Karafka-Testing is a library that provides rspec helpers, to make testing of Karafka consumers much easier.

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

Once included into your RSpec setup, this library will provide you two methods that you can use with your specs:

- `#karafka_consumer_for` - this method will create a consumer instance for the desired topic. It **needs** to be set as the spec subject.
- `#publish_for_karafka` - this method will "send" message to the consumer instance.


**Note:** Messages sent using the `#publish_for_karafka` method won't be sent to Kafka. They will be "virtually" delegated to the created consumer instance so your specs can run without Kafka setup.

```ruby
RSpec.describe InlineBatchConsumer do
  # This will create a consumer instance with all the settings defined for the given topic
  subject(:consumer) { karafka_consumer_for(:inline_batch_data) }

  let(:nr1_value) { rand }
  let(:nr2_value) { rand }
  let(:sum) { nr1_value + nr2_value }

  before do
    # Sends first message to Karafka consumer
    publish_for_karafka({ 'number' => nr1_value }.to_json)
    # Sends second message to Karafka consumer
    publish_for_karafka({ 'number' => nr2_value }.to_json)
    allow(Karafka.logger).to receive(:info)
  end

  it 'expects to log a proper message' do
    expect(Karafka.logger).to receive(:info).with("Sum of 2 elements equals to: #{sum}")
    consumer.consume
  end
end
```

## References

* [Karafka framework](https://github.com/karafka/karafka)
* [Karafka Testing Actions CI](https://github.com/karafka/testing/actions?query=workflow%3Aci)
* [Karafka Testing Coditsu](https://app.coditsu.io/karafka/repositories/testing)

## Note on contributions

First, thank you for considering contributing to Karafka Testing! It's people like you that make the open source community such a great community!

Each pull request must pass all the RSpec specs and meet our quality requirements.

To check if everything is as it should be, we use [Coditsu](https://coditsu.io) that combines multiple linters and code analyzers for both code and documentation. Once you're done with your changes, submit a pull request.

Coditsu will automatically check your work against our quality standards. You can find your commit check results on the [builds page](https://app.coditsu.io/karafka/repositories/testing/builds/commit_builds) of the Karafka Testing repository.
