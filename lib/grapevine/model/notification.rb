class Notification
  include ::DataMapper::Resource
  belongs_to :topic

  property :id,         Serial
  property :source,     String, :index => true
  property :content,    Text, :length => 65535
  property :created_at, DateTime

  validates_presence_of :source
  validates_presence_of :created_at
end
