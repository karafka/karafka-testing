# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'karafka/testing/version'

Gem::Specification.new do |spec|
  spec.name          = 'karafka-testing'
  spec.platform      = Gem::Platform::RUBY
  spec.version       = Karafka::Testing::VERSION
  spec.authors       = ['Maciej Mensfeld']
  spec.email         = %w[contact@karafka.io]
  spec.summary       = 'Library which provides helpers for easier Karafka consumers tests'
  spec.description   = 'Library which provides helpers for easier Karafka consumers tests'
  spec.homepage      = 'https://karafka.io'
  spec.license       = 'MIT'
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(spec)/}) }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = %w[lib]
  spec.cert_chain    = %w[certs/cert_chain.pem]

  if $PROGRAM_NAME.end_with?('gem')
    spec.signing_key = File.expand_path('~/.ssh/gem-private_key.pem')
  end

  spec.add_dependency 'karafka', '>= 2.0.20', '< 3.0.0'

  spec.metadata = {
    'source_code_uri' => 'https://github.com/karafka/karafka-testing',
    'rubygems_mfa_required' => 'true'
  }
end
