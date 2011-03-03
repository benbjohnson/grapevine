module Grapevine
  # This is an abstract base class for all loaders in the system. The loader
  # imports messages in from a source and aggregates them into topics.
  class Loader
    ############################################################################
    # Static Attributes
    ############################################################################
    
    # Registers a class by type
    def self.register(type, clazz)
      @classes ||= {}
      @classes[type] = clazz
    end
    
    # Creates an instance of a loader by type
    #
    # @param [String] type  the type of loader to create.
    # @param [Hash] options  a list of options to set on the loader.
    #
    # @return [Grapevine::Loader]  the new instance of a loader.
    def self.create(type, options={})
      @classes ||= {}
      clazz = @classes[type]
      raise "No loader has been registered as: #{type}" if clazz.nil?
      loader = clazz.new

      # Set options
      options = options.symbolize
      
      # Required attributes
      name = options.delete(:name)
      raise "Name required on loader definition" if name.nil?
      raise "Frequency required on loader: #{name}" if options[:frequency].nil?

      # Set the loader name
      loader.name = name
      
      # Parse frequency
      loader.frequency = Date.parse_time_period(options[:frequency])
      raise "Invalid frequency: #{frequency}" if loader.frequency.nil?
      options.delete(:frequency)
      
      # Set attributes on the loader
      options.each do |k, v|
        loader.__send__ "#{k.to_str}=", v
      end

      return loader
    end

    

    ############################################################################
    # Public Attributes
    ############################################################################

    # The name of this loader type.
    attr_accessor :name

    # The frequency that this loader should run.
    attr_accessor :frequency
    

    ############################################################################
    # Public Methods
    ############################################################################

    # Loads a list of messages.
    def load()
    end
  end
end