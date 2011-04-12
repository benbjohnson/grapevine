# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require 'grapevine/version'

Gem::Specification.new do |s|
  s.name        = 'grapevine'
  s.version     = Grapevine::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ['Ben Johnson']
  s.email       = ['benbjohnson@yahoo.com']
  s.homepage    = 'http://github.com/benbjohnson/grapevine'
  s.summary     = 'Message aggregator'
  s.executables = ['grapevine', 'grapevined']
  s.default_executable = 'grapevine'

  s.add_dependency('rack', '= 1.2.0')
  s.add_dependency('OptionParser', '~> 0.5.1')
  s.add_dependency('daemons', '~> 1.1.0')
  s.add_dependency('data_mapper', '~> 1.0.2')
  s.add_dependency('topsy', '~> 0.3.4')
  s.add_dependency('octopi', '~> 0.4.0')
  s.add_dependency('bitly', '~> 0.6.1')
  s.add_dependency('twitter', '~> 1.3.0')
  s.add_dependency('commander', '~> 4.0.3')
  s.add_dependency('terminal-table', '~> 1.4.2')
  s.add_dependency('slowweb', '~> 0.1.1')
  s.add_dependency('log4r', '~> 1.1.6')
  s.add_dependency('unindentable', '~> 0.1.0')

  s.add_development_dependency('rspec', '~> 2.4.0')
  s.add_development_dependency('mocha', '~> 0.9.12')
  s.add_development_dependency('fakeweb', '~> 1.3.0')
  s.add_development_dependency('timecop', '~> 0.3.5')
  s.add_development_dependency('rcov', '~> 0.9.9')
  s.add_development_dependency('dm-sqlite-adapter', '~> 1.0.2')

  s.test_files   = Dir.glob('test/**/*')
  s.files        = Dir.glob('lib/**/*') + %w(README.md)
  s.require_path = 'lib'
end
