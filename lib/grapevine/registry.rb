module Grapevine
  # This class manages a group of loaders and notifiers. It can instantiate
  # objects from a YAML configuration file.
  class Registry
    ############################################################################
    # Constructor
    ############################################################################

    def initialize()
      @loaders   = []
      @notifiers = []
    end


    ############################################################################
    # Public Attributes
    ############################################################################

    # The list of registered loaders.
    attr_reader :loaders

    # The list of registered notifiers.
    attr_reader :notifiers
    

    ############################################################################
    # Public Methods
    ############################################################################

    ###################################
    # Loaders
    ###################################

    # Registers a loader to the registry.
    #
    # @param [Grapevine::Loader] loader  the loader to add.
    def add_loader(loader)
      @loaders << loader
    end

    # Unregisters a loader from the registry.
    #
    # @param [Grapevine::Loader] loader  the loader to remove.
    def remove_loader(loader)
      @loaders.delete(loader)
    end


    ###################################
    # Notifiers
    ###################################

    # Registers a notifier to the registry.
    #
    # @param [Grapevine::Notifier] notifier  the notifier to add.
    def add_notifier(notifier)
      @notifiers << notifier
    end

    # Unregisters a notifier from the registry.
    #
    # @param [Grapevine::Notifier] notifier  the notifier to remove.
    def remove_notifier(notifier)
      @notifiers.delete(notifier)
    end


    ###################################
    # Configuration
    ###################################

    # Creates a set of loaders and notifiers based on a YAML config.
    #
    # @param [String] filename  the path to the YAML config file.
    def load_config(filename)
      data = YAML.load(IO.read(filename))
      
      # Create loaders
      if data.key?('sources') && data['sources'].is_a?(Array)
        data['sources'].each do |hash|
          type = hash.delete('type')
          loader = Grapevine::Loader.create(type, hash)
          add_loader(loader)
        end
      end

      # Create notifiers
      if data.key?('notifiers') && data['notifiers'].is_a?(Array)
        data['notifiers'].each do |hash|
          type = hash.delete('type')
          notifier = Grapevine::Notifier.create(type, hash)
          add_notifier(notifier)
        end
      end
      
      nil
    end
  end
end