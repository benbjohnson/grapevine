module Grapevine
  class Topic
    include ::DataMapper::Resource
    has n, :messages
    has n, :tags

    property :id,     Serial
    property :source, String
    property :name,   String
    property :url,    Text
    property :created_at, DateTime
    timestamps :at

    validates_presence_of :source
    validates_presence_of :name
  end
end