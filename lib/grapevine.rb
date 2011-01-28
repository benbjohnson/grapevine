$:.unshift(File.dirname(__FILE__))

require 'open-uri'
require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'
require 'topsy'
require 'octopi'
require 'slowweb'

require 'grapevine/loader'
require 'grapevine/model'
require 'grapevine/twitter'
require 'grapevine/version'

# Setup the request governor
SlowWeb.limit('github.com', 60, 60)