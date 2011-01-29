dir = File.dirname(File.expand_path(__FILE__))
$:.unshift(File.join(dir, '..', 'lib'))
$:.unshift(dir)

require 'rubygems'
require 'bundler/setup'
require 'grapevine'

require 'rspec'
require 'fakeweb'
require 'timecop'

# Configure RSpec
Rspec.configure do |c|
  c.mock_with :rspec
end

# Setup DataMapper
DataMapper.setup(:default, 'sqlite::memory:')
DataMapper.auto_upgrade!
