class Topic
  include ::DataMapper::Resource
  has n, :messages
  has n, :tags
  has n, :notifications

  property :id,          Serial
  property :source,      String
  property :name,        String
  property :description, Text, :length => 65535
  property :url,         Text, :length => 65535
  property :created_at,  DateTime
  timestamps :at

  validates_presence_of :source
  validates_presence_of :name
end