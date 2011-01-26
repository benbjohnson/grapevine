module Grapevine
  class Message
    include ::DataMapper::Resource
    belongs_to :topic

    property :id,        Serial
    property :source,    String
    property :source_id, String
    property :author,    String
    property :url,       Text
    timestamps :at

    validates_presence_of :topic_id
    
    ############################################################################
    # Public Attributes
    ############################################################################
    
    # A list of tags on the message. These are not persisted to the database but
    # are added to the topic that this message is grouped under.
    attr_accessor :tag_list
  end
end