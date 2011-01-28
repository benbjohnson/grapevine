dir = File.dirname(File.expand_path(__FILE__))
$:.unshift(File.join(dir, '..', 'lib'))
$:.unshift(dir)

require 'rubygems'
require 'bundler/setup'
require 'rspec'
require 'fakeweb'
require 'grapevine'

# Configure RSpec
Rspec.configure do |c|
  c.mock_with :rspec
end

# Setup DataMapper
DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.auto_upgrade!
