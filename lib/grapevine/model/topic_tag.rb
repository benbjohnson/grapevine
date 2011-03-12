class TopicTag
  include ::DataMapper::Resource

  property :topic_id,   Integer, :key => true, :min => 1
  property :tag_id, Integer, :key => true, :min => 1

  belongs_to :topic, :key => true
  belongs_to :tag, :key => true
end