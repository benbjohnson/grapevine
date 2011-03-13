module Grapevine
  module Twitter
    # This class sends notifications as Twitter tweets.
    class TweetNotifier < Grapevine::Notifier
      ##########################################################################
      # Setup
      ##########################################################################

      Grapevine::Notifier.register('twitter', self)
      

      ##########################################################################
      # Constructor
      ##########################################################################

      def initialize
      end


      ##########################################################################
      # Public Attributes
      ##########################################################################

      # The frequency that notifications can be sent. This is specified in
      # seconds.
      attr_accessor :frequency

      # The Twitter username that will post the status update.
      attr_accessor :username
      
      # The OAuth token used to authenticate to Twitter.
      attr_accessor :oauth_token
      
      # The OAuth token secret used to authenticate to Twitter.
      attr_accessor :oauth_token_secret
      

      ##########################################################################
      # Public Methods
      ##########################################################################

      # The current state of the notifier. Will be "ready" if it is ready to
      # send a notification or "waiting" if the specified frequency has not
      # elapsed since the last notification.
      def state
        if !frequency.nil? && frequency > 0
          notification = Notification.first(
            :source => self.name,
            :order => :created_at.desc
          )

          elapsed = Time.now-Time.parse(notification.created_at.to_s)
          if notification && elapsed < frequency
            return 'waiting'
          end
        end
        
        return 'ready'
      end

      # Sends a notification for the most popular topic.
      def send(options={})
        force = options[:force]
        
        # Wait if the nofifier is not ready
        return if !force && state == 'waiting'
          
        # Wait at least the number of seconds specified in frequency before
        # sending another notification
        if !force && !frequency.nil? && frequency > 0
          notification = Notification.first(
            :source => self.name,
            :order => :created_at.desc
          )

          if notification && Time.now-Time.parse(notification.created_at.to_s) < frequency
            return
          end
        end
        
        # Find most popular topic
        topic = popular_topics.first
        return false if topic.nil?
        
        # Shorten the topic URL
        bitly = Bitly.new(Grapevine::Config.bitly_username, Grapevine::Config.bitly_api_key)
        url = bitly.shorten(topic.url).short_url

        # Configure Twitter API
        ::Twitter.configure do |config|
          config.consumer_key = Grapevine::Config.twitter_consumer_key
          config.consumer_secret = Grapevine::Config.twitter_consumer_secret
          config.oauth_token = self.oauth_token
          config.oauth_token_secret = self.oauth_token_secret
        end

        # Limit description length
        description = topic.description || ''
        max_length = 140 - topic.name.length - url.length - username.length - 10
        if description.length > max_length
          # Try to cut off at the last space if possible
          index = description.rindex(' ', max_length) || max_length
          description = description[0..index-1]
        end
        
        # Build tweet message
        content = "#{topic.name} - #{description} #{url}"
        
        # Send tweet
        client = ::Twitter::Client.new
        client.update(content);
        
        # Log notification
        Notification.create(
          :topic => topic,
          :source => name,
          :content => content,
          :created_at => Time.now
        )

        Grapevine.log.debug "Notify: #{name} -> #{topic.name}"
      end
    end
  end
end