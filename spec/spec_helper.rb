dir = File.dirname(File.expand_path(__FILE__))
$:.unshift(File.join(dir, '..', 'lib'))
$:.unshift(dir)

require 'rubygems'
require 'bundler/setup'
require 'grapevine'

require 'rspec'
require 'mocha'
require 'unindentable'
require 'fakeweb'
require 'timecop'

# Configure RSpec
Rspec.configure do |c|
  c.mock_with :mocha
end

# Setup DataMapper
DataMapper.setup(:default, 'sqlite::memory:')

# Turn off log
Grapevine.log.outputters = []