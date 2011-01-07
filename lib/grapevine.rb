$:.unshift(File.dirname(__FILE__))

require 'dm-core'
require 'dm-migrations'
require 'dm-timestamps'
require 'dm-validations'
require 'dm-tags'
require 'topsy'
require 'octopi'

require 'grapevine/loaders'
require 'grapevine/model'
require 'grapevine/version'

DataMapper.finalize
