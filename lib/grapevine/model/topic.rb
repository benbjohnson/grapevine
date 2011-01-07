module Grapevine
  class Topic
    include ::DataMapper::Resource
    has n, :message

    property :id,     Serial
    property :source, String
    property :name,   String
    property :url,    String
    property :created_at, DateTime
    has_tags
    timestamps :at

    validates_presence_of :source
    validates_presence_of :name
  end
end