module Grapevine
  # This is an abstract base class for all notifiers in the system. The notifier
  # announces the most popular topic.
  class Notifier
    ############################################################################
    # Static Attributes
    ############################################################################
    
    # Registers a class by name
    def self.register(name, clazz)
      @classes ||= {}
      @classes[name] = clazz
    end
    
    # Creates an instance of a notifier by name
    def self.create(name)
      @classes ||= {}
      clazz = @classes[name]
      raise "No notifier has been registered as: #{name}" if clazz.nil?
      instance = clazz.new
    end

    

    ############################################################################
    # Constructor
    ############################################################################

    def initialize(name)
      @name = name
    end


    ############################################################################
    # Public Attributes
    ############################################################################

    # The name of this notifier type.
    attr_reader :name

    # The name of the source to retrieve topics from.
    attr_accessor :source

    # A list of tags to filter topics by.
    attr_accessor :tags

    # A time window in which topics can not be renotified. This window is
    # defined in seconds.
    attr_accessor :window
    

    ############################################################################
    # Public Methods
    ############################################################################

    # Sends a notification.
    def send()
    end

    
    # A list of the most popular topics.
    def popular_topics
      topics = []
      results = repository.adapter.select('SELECT t.id, t.name, COUNT(*) count FROM grapevine_topics t INNER JOIN grapevine_messages m ON t.id = m.topic_id GROUP BY t.id ORDER BY COUNT(*) DESC')
      
      # Loop over aggregate results
      results.each do |result|
        topic = Grapevine::Topic.get(result.id)
        
        # Skip topic if it has been notified within the window
        notification = *topic.notifications(:source => name, :order => :created_at.desc)
        next if notification && Time.now-Time.parse(notification.created_at.to_s) < window

        # Skip topic if it doesn't contain any of the filtered tags
        if tags && tags.length > 0
          found = false
          tags.each do |tag|
            if topic.tags(:id => tag.id).length > 0
              found = true
              break
            end
          end
          next unless found
        end
        
        # If validations have all passed, add the topic to the list
        topics << topic
      end

      return topics
    end
  end
end