DataMapper::Model.raise_on_save_failure = true

DataMapper::Property::String.length(255)
DataMapper::Property::Boolean.allow_nil(false)

require 'grapevine/model/topic'
require 'grapevine/model/tag'
require 'grapevine/model/notification'
require 'grapevine/model/message'

DataMapper.finalize
