# Karafka Testing library

[![Build Status](https://travis-ci.org/karafka/test.svg)](https://travis-ci.org/karafka/testing)
[![Join the chat at https://gitter.im/karafka/karafka](https://badges.gitter.im/karafka/karafka.svg)](https://gitter.im/karafka/karafka?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Karafka-Testing is a library that provides rspec helpers, to make testing of Karafka consumers much easier.

## Installation

Add the gem to your Gemfile
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



## References

* [Karafka framework](https://github.com/karafka/karafka)
* [Karafka Testing Travis CI](https://travis-ci.org/karafka/testing)
* [Karafka Testing Coditsu](https://app.coditsu.io/karafka/repositories/testing)

## Note on contributions

First, thank you for considering contributing to Karafka Testing! It's people like you that make the open source community such a great community!

Each pull request must pass all the RSpec specs and meet our quality requirements.

To check if everything is as it should be, we use [Coditsu](https://coditsu.io) that combines multiple linters and code analyzers for both code and documentation. Once you're done with your changes, submit a pull request.

Coditsu will automatically check your work against our quality standards. You can find your commit check results on the [builds page](https://app.coditsu.io/karafka/repositories/test/builds/commit_builds) of the Karafka Testing repository.

[![coditsu](https://coditsu.io/assets/quality_bar.svg)](https://app.coditsu.io/karafka/repositories/testing/builds/commit_builds)
