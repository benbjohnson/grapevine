module Grapevine
  # This is an abstract base class for all notifiers in the system. The notifier
  # announces the most popular topic.
  class Notifier
    ############################################################################
    # Static Attributes
    ############################################################################
    
    # Registers a class by type
    def self.register(type, clazz)
      @classes ||= {}
      @classes[type] = clazz
    end

    # Creates an instance of a notifier by type
    #
    # @param [String] type  the type of notifier to create.
    # @param [Hash] options  a list of options to set on the notifier.
    #
    # @return [Grapevine::Notifier]  the new instance of a notifier.
    def self.create(type, options={})
      @classes ||= {}
      clazz = @classes[type]
      raise "No notifier has been registered as: #{type}" if clazz.nil?
      notifier = clazz.new

      # Set options
      options = options.symbolize
      
      # Required attributes
      name = options.delete(:name)
      raise "Name required on notifier definition" if name.nil?
      raise "Frequency required on notifier: #{name}" if options[:frequency].nil?

      # Set the notifier name
      notifier.name = name
      
      # Parse frequency
      notifier.frequency = Date.parse_time_period(options[:frequency])
      raise "Invalid frequency: #{frequency}" if notifier.frequency.nil?
      options.delete(:frequency)

      # Parse window
      if options.key?(:window)
        notifier.window = Date.parse_time_period(options[:window])
        raise "Invalid window: #{window}" if notifier.window.nil?
        options.delete(:window)
      end
      
      # Set attributes on the notifier
      options.each do |k, v|
        notifier.__send__ "#{k.to_s}=", v
      end

      return notifier
    end


    ############################################################################
    # Constructor
    ############################################################################

    def initialize()
    end


    ############################################################################
    # Public Attributes
    ############################################################################

    # The name of this notifier.
    attr_accessor :name

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
    def send(options={})
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