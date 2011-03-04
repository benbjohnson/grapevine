module Grapevine
  # This class holds configuration settings loaded from the local config file
  # or set by the command line.
  class Config
    ##########################################################################
    # Static Methods
    ##########################################################################

    def self.method_missing(sym, *args, &block)
      self.config.__send__ sym, *args, &block
    end

    def self.config
      @config ||= self.new
    end

    def self.config=(value)
      @config = value
    end


    ##########################################################################
    # Bit.ly API
    ##########################################################################

    # The username used to login to bit.ly's API.
    attr_accessor :bitly_username

    # The API key used to login to bit.ly's API.
    attr_accessor :bitly_api_key


    ##########################################################################
    # Twitter API
    ##########################################################################

    # The consumer key used to login to Twitter's API.
    attr_accessor :twitter_consumer_key

    # The consumer secret used to login to Twitter's API.
    attr_accessor :twitter_consumer_secret



    ##########################################################################
    # Public Methods
    ##########################################################################
    
    # Loads the configuration from a hash.
    #
    # @param [Hash] hash  a hash of configuration settings to set.
    def load(hash)
      hash.each_pair do |key, value|
        mutator_name = "#{key.to_s}="
        self.__send__(mutator_name, value) if methods.include?(mutator_name)
      end
    end
    
    # Loads the configuration from a file.
    #
    # @param [String] filename  the YAML configuration file to load.
    def load_file(filename='~/grapevine.yml')
      filename = File.expand_path(filename)
      hash = YAML.load(File.open(filename))
      load(hash)
    end
  end
end