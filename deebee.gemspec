# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'deebee/version'

Gem::Specification.new do |spec|
  spec.name          = 'deebee'
  spec.version       = Deebee::VERSION
  spec.authors       = ['Rafaël Blais Masson']
  spec.email         = ['rafbmasson@gmail.com']
  spec.description   = 'Deebee is a convenient and fast web interface for your DB. As a Sinatra app, it can be used standalone or mounted within your Rails app.'
  spec.summary       = 'Web client for your DB'
  spec.homepage      = 'http://github.com/rafBM/deebee'
  spec.license       = 'MIT'

  spec.files         = `git ls-files | grep -Ev '^(examples)'`.split("\n")
  spec.require_paths = ['lib']

  spec.add_dependency 'sinatra', '>= 1.2'
  spec.add_dependency 'sequel', '>= 3.0'

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rake'
end
