# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'enter_rockstar/version'

Gem::Specification.new do |spec|
  spec.name          = 'enter-rockstar'
  spec.version       = EnterRockstar::VERSION
  spec.authors       = ['Marcin Ruszkiewicz']
  spec.email         = ['marcin.ruszkiewicz@polcode.net']

  spec.summary       = 'Generating helpful Rock phrases to make programming in Rockstar easier.'
  spec.homepage      = 'https://github.com/marcinruszkiewicz/enter-rockstar'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(spec|examples)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = ['enter-rockstar']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.3'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'fakefs'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'vcr'
  spec.add_development_dependency 'webmock'

  spec.add_dependency 'nokogiri'
  spec.add_dependency 'progressbar'
  spec.add_dependency 'thor'
  spec.add_dependency 'whatlanguage'
end
