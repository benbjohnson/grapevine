module Grapevine
  module Twitter
    # This class loads trackbacks from Twitter using the Topsy service. The
    # loader accepts a site to search within and has the ability to filter
    # trackbacks as they come in.
    class TrackbackLoader < Grapevine::Loader
      ##########################################################################
      # Setup
      ##########################################################################

      Grapevine::Loader.register('twitter-trackback', self)
      

      ##########################################################################
      # Constructor
      ##########################################################################

      def initialize
        @per_page = 10
        @duplicate_max_count = 10
      end


      ##########################################################################
      # Public Attributes
      ##########################################################################

      # A URL describing the domain to search within.
      attr_accessor :site

      # The number of items to return per page.
      attr_accessor :per_page

      # The number of times duplicates can be found before the search is
      # stopped.
      attr_accessor :duplicate_max_count
      

      ##########################################################################
      # Public Methods
      ##########################################################################

      # Loads a list of trackbacks from Twitter for a given site.
      def load()
        raise 'Cannot load trackbacks without a site defined' if site.nil?
        
        # Paginate through search
        page = 1
        duplicate_count = 0
        
        begin
          results = Topsy.search(site, :window => :realtime, :page => page, :perpage => per_page)
        
          # Loop over links and load trackbacks for each one
          results.list.each do |item|
            # Create and append message
            message = create_message(item)
            
            if !message.nil?
              # Skip message if it's a duplicate
              if Grapevine::Message.first(:source_id => message.source_id)
                duplicate_count += 1
                
                # Exit if we've encountered too many duplicates
                if duplicate_count > duplicate_max_count
                  return
                # Otherwise continue to next item
                else
                  next;
                end
              # Reset the duplicate count if we see a new tweet
              else
                duplicate_count = 0
              end

              # Attempt to create a topic
              topic = create_topic(message)
              if topic.nil?
                next
              end
              
              # Only count tweets from an author once
              if Grapevine::Message.first(:topic => topic, :author => message.author)
                next
              end

              # Assign topic and save message
              message.topic = topic
              message.save

              Grapevine.log.debug "MESSAGE: [#{message.author}] #{message.content}"
            end
          end

          page += 1
        end while results.last_offset < results.total && page < 10
      end


      ##########################################################################
      # Protected Methods
      ##########################################################################

      protected
      
      # Creates a message from a tweet.
      def create_message(item)
        # Extract tweet identifier
        m, id = *item.trackback_permalink.match(/(\d+)$/)
        
        message = Grapevine::Message.new()
        message.source     = name
        message.source_id  = id
        message.author     = item.trackback_author_nick
        message.url        = item.url
        message.content    = item.content
        message.created_at = Time.at(item.trackback_date)
        
        return message
      end

      # Creates a topic from a message
      def create_topic(message, url=nil)
        url ||= message.url
        
        topic = Grapevine::Topic.first(:url => url)
        
        if topic.nil?
          topic = Grapevine::Topic.new(:source => name, :url => url)
          set_topic_name(topic)
          
          Grapevine.log.debug "#{topic.errors.full_messages.join(',')}" unless topic.valid?
          topic.save
          Grapevine.log.debug "TOPIC: #{topic.name}"
        end
        
        return topic
      end

      # Generates a topic name
      def set_topic_name(topic)
        topic_name = ''
        
        # Find topic name from the title of the URL
        open(topic.url) do |f|
          m, topic_name = *f.read.match(/<title>(.+?)<\/title>/)
          topic_name ||= '<unknown>'
        end

        topic.name = topic_name[0..250]
      end
    end
  end
end