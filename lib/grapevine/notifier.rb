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
      # Retrieve a union of topics based on tags
      topics = []
      if tags && tags.length > 0
        tags.each do |tag|
          m, tag_type, tag_value = *tag.match(/^(\w+):(.+)$/)
          db_tag = Tag.first(:type => tag_type, :value => tag_value)
          topics |= db_tag.topics
        end
      # If no tags are specified, use all topics
      else
        topics = Topic.all
      end
      
      # Loop over aggregate results
      topics.each do |topic|
        # Remove topic if it has been notified within the window
        notification = topic.notifications.first(:source => name, :order => :created_at.desc)
        
        if notification
          elapsed = Time.now-Time.parse(notification.created_at.to_s)
          if elapsed > window
            topics.delete(topic)
          end
        end
      end

      # Sort topics by popularity
      topics = topics.sort! {|x,y| x.messages.length <=> y.messages.length}
      topics.reverse!
      
      return topics
    end
  end
end