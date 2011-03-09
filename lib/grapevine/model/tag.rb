class Tag
  include ::DataMapper::Resource
  belongs_to :topic

  property :id,    Serial
  property :type,  String
  property :value, String

  validates_presence_of :type
  validates_presence_of :value
end