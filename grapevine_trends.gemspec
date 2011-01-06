# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'grapevine/version'

Gem::Specification.new do |s|
  s.name        = "grapevine"
  s.version     = Grapevine::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Ben Johnson"]
  s.email       = ["benbjohnson@yahoo.com"]
  s.homepage    = "http://github.com/benbjohnson/grapevine"
  s.summary     = "Social aggregator"
  #s.executables = ['grapevine']
  #s.default_executable = 'grapevine'

  #s.add_dependency('topsy', '~> 0.3.2')
  s.add_dependency('OptionParser', '~> 0.5.1')
  s.add_dependency('daemons', '~> 1.1.0')

  s.add_development_dependency('rake', '~> 0.8.3')
  s.add_development_dependency('minitest', '~> 1.7.0')
  s.add_development_dependency('mocha', '~> 0.9.8')

  s.test_files   = Dir.glob("test/**/*")
  s.files        = Dir.glob("lib/**/*") + %w(README.md)
  s.require_path = 'lib'
end
