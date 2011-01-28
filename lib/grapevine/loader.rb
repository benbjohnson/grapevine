module Grapevine
  # This is an abstract base class for all loaders in the system. The loader
  # imports messages in from a source and aggregates them into topics.
  class Loader
    ############################################################################
    # Static Attributes
    ############################################################################
    
    # Registers a class by name
    def self.register(name, clazz)
      @classes ||= {}
      @classes[name] = clazz
    end
    
    # Creates an instance of a loader by name
    def self.create(name)
      @classes ||= {}
      clazz = @classes[name]
      raise "No loader has been registered as: #{name}" if clazz.nil?
      instance = clazz.new
    end

    

    ############################################################################
    # Public Attributes
    ############################################################################

    # The name of this loader type.
    attr_reader :name
    

    ############################################################################
    # Public Methods
    ############################################################################

    # Loads a list of messages.
    def load()
      []
    end
  end
end