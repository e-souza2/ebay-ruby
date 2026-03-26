# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'ebay-api'
  spec.version       = "0.1.0"
  spec.authors       = ['Eduardo Souza']
  spec.email         = ['eduardo@eduardosouza.com']

  spec.summary       = 'Ruby gem for the eBay REST APIs'
  spec.description   = 'Ruby gem for integrating with eBay REST APIs. Supports Browse API, Finding API, and Taxonomy API with OAuth 2.0 authentication.'
  spec.homepage      = 'https://github.com/ESouza/ebay-api'
  spec.license       = 'MIT'
  spec.required_ruby_version = '>= 2.7.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage
  spec.metadata['changelog_uri'] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  spec.files = Dir.glob('{lib,spec}/**/*') + %w[README.md LICENSE.txt CHANGELOG.md]
  spec.require_paths = ['lib']

  spec.add_dependency 'base64', '>= 0.1'
  spec.add_dependency 'httparty', '~> 0.21'
  spec.add_dependency 'json', '~> 2.6'

  spec.add_development_dependency 'bundler', '>= 2.0'
  spec.add_development_dependency 'dotenv', '~> 2.8'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.12'
  spec.add_development_dependency 'rubocop', '~> 1.50'
  spec.add_development_dependency 'webmock', '~> 3.18'
end
