class Tag
  include ::DataMapper::Resource
  has n, :topic_tags
  has n, :topics, :through => :topic_tags

  property :id,    Serial
  property :type,  String, :unique_index => :type_value
  property :value, String, :unique_index => :type_value

  validates_presence_of :type
  validates_presence_of :value
end