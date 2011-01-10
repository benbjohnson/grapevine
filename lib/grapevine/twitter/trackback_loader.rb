module Grapevine
  module Twitter
    # This class loads trackbacks from Twitter using the Topsy service. The
    # loader accepts a site to search within and has the ability to filter
    # trackbacks as they come in.
    class TrackbackLoader
      ############################################################################
      # Constructor
      ############################################################################

      def initialize
        @name = 'twitter-trackback'
        @per_page = 10
      end


      ############################################################################
      # Public Attributes
      ############################################################################

      # The name of this loader type.
      attr_accessor :name

      # A URL describing the domain to search within.
      attr_accessor :site

      # The number of items to return per page.
      attr_accessor :per_page

      # A timestamp for the most recent trackback that was loaded.
      attr_accessor :timestamp
      

      ############################################################################
      # Public Methods
      ############################################################################

      # Loads a list of trackbacks from Twitter for a given site.
      def load()
        raise 'Cannot load trackbacks without a site defined' if site.nil?
        
        # Paginate through search
        messages = []
        page = 1
        last_loaded_at = timestamp
        
        begin
          results = Topsy.search(site, :window => :realtime, :page => page, :perpage => per_page)
        
          # Loop over links and load trackbacks for each one
          results.list.each do |item|
            # Stop searching if we are past our last timestamp
            created_at = Time.at(item.trackback_date)
            page = 99999 && break if !last_loaded_at.nil? && created_at <= last_loaded_at
            self.timestamp = created_at if timestamp.nil?
            
            # Extract tweet identifier
            m, id = *item.trackback_permalink.match(/(\d+)$/)

            # Create message
            message = Message.new()
            message.source     = name
            message.source_id  = id
            message.author     = item.trackback_author_nick
            message.url        = item.url
            message.created_at = created_at
            
            # Add message to list
            messages << message
          end

          page += 1
        end while results.last_offset < results.total && page < 10
        
        return messages
      end
    end
  end
end