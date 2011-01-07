module Grapevine
  class Message
    include ::DataMapper::Resource
    belongs_to :topic

    property :id,         Serial
    property :source_id,  String
    property :author,     String
    timestamps :at

    validates_presence_of :topic_id
  end
end