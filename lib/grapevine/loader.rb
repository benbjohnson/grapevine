module Grapevine
  # This is an abstract base class for all loaders in the system. All loaders
  # must implement both the load() method and the aggregate method. The load
  # method will retrieve a list of messages and the aggregate method will group
  # those messages into relavent topics.
  class Loader
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

    # Groups a list of messages into topics.
    def aggregate(messages)
      []
    end
  end
end