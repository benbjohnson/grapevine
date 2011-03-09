$:.unshift(File.dirname(__FILE__))

require 'log4r'
require 'yaml'
require 'open-uri'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'
require 'topsy'
require 'octopi'
require 'twitter'
require 'bitly'
require 'slowweb'
require 'unindentable'

require 'grapevine/ext/date'
require 'grapevine/ext/hash'

require 'grapevine/config'
require 'grapevine/loader'
require 'grapevine/model'
require 'grapevine/notifier'
require 'grapevine/registry'
require 'grapevine/twitter'
require 'grapevine/version'

# Setup the request governor
SlowWeb.limit('github.com', 60, 60)

# Use Bit.ly API v3
Bitly.use_api_version_3

module Grapevine
  def self.log
    if @log.nil?
      @log = Log4r::Logger.new('')
      @log.outputters = [
        Log4r::FileOutputter.new(
          'error_log',
          :level => Log4r::ERROR,
          :filename => File.expand_path('~/grapevine.log')
        ),
        Log4r::Outputter.stdout
      ]
    end
    
    return @log
  end

  def self.log_error(message, error)
    log.error "#{message}: #{error.inspect}\n#{error.backtrace}"
  end
end