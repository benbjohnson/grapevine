class Message
  include ::DataMapper::Resource
  belongs_to :topic

  property :id,        Serial
  property :source,    String
  property :source_id, String
  property :author,    String
  property :url,       Text
  property :content,   Text
  timestamps :at

  validates_presence_of :topic_id
end
