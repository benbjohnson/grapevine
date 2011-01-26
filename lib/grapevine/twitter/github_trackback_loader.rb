module Grapevine
  module Twitter
    # This class loads trackbacks from Twitter that point to a GitHub project.
    # This loader also retrieves meta data about the project from the GitHub
    # API.
    class GitHubTrackbackLoader < TrackbackLoader
      ##########################################################################
      # Constructor
      ##########################################################################

      def initialize
        super
        @name = 'twitter-github'
        @site = 'github.com'
        @language_threshold = 20
      end


      ##########################################################################
      # Public Attributes
      ##########################################################################

      # The percentage of total bytes of a GitHub project that should use a
      # language in order to be tagged.
      attr_accessor :language_threshold
      

      ##########################################################################
      # Protected Methods
      ##########################################################################
      
      # Creates a message from a tweet.
      def create_message(item)
        username, repo_name = *extract_repo_info(item.url)

        # Skip tweet if it's not a GitHub project url
        return nil if username.nil?
        
        # Otherwise create the message and reformat the URL
        message = super(item)
        message.url = "https://github.com/#{username}/#{repo_name}"
        
        return message
      end

      # Creates a topic from a message
      def create_topic(message)
        topic = super(message)
                
        username, repo_name = *extract_repo_info(message.url)
        repo = Octopi::User.find(username).repository(repo_name)

        get_repository_language_tags(repo).each do |language|
          tag = Grapevine::Tag.create(
            :topic => topic,
            :type  => 'language',
            :value => language
          )
        end
        
        return topic
      end

      # Generates a topic name
      def create_topic_name(topic)
        username, repo_name = *extract_repo_info(topic.url)
        repo = Octopi::User.find(username).repository(repo_name)
        topic_name = "#{repo.name}: #{repo.description}"
        return topic_name[0..250]
      end
      
      
      ##########################################################################
      # Private Methods
      ##########################################################################

      # Parses a GitHub URL and extracts repo information
      def extract_repo_info(url)
        m, username, repo_name = *url.match(/^https?:\/\/(?:www.)?github.com\/([^\/]+)\/([^\/]+)/i)
        return (m ? [username, repo_name] : nil)
      end

      # Retrieves a list of language tags associated with a repository.
      def get_repository_language_tags(repo)
        lookup = repo.languages
        total = lookup.values.inject(0) {|s,v| s += v}
      
        # Find languages that meet the threshold
        languages = []
        lookup.each_pair do |k,v|
          k = k.downcase.gsub(/\s+/, '-')
          languages << k if v >= total*(language_threshold/100)
        end
      
        return languages
      end
    end
  end
end