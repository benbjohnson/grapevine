module Grapevine
  module Twitter
    # This class loads trackbacks from Twitter that point to a GitHub project.
    # This loader also retrieves meta data about the project from the GitHub
    # API.
    class GitHubTrackbackLoader < TrackbackLoader
      ##########################################################################
      # Setup
      ##########################################################################

      Grapevine::Loader.register('twitter-github', self)
      

      ##########################################################################
      # Constructor
      ##########################################################################

      def initialize
        super
        @site = 'github.com'
        @language_threshold = 30
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
        if username.nil?
          return nil
        else
          return super(item)
        end
      end

      # Creates a topic from a message
      def create_topic(message, url=nil)
        # Reformat the URL
        username, repo_name = *extract_repo_info(message.url)
        url = "https://github.com/#{username}/#{repo_name}"

        topic = super(message, url)
        
        # Ignore GitHub info if call fails
        begin
          repo = Octopi::User.find(username).repository(repo_name)

          get_repository_language_tags(repo).each do |language|
            tag = Grapevine::Tag.create(
              :topic => topic,
              :type  => 'language',
              :value => language
            )
          end
        rescue Exception
        end
        
        return topic
      end

      # Generates a topic name
      def set_topic_name(topic)
        username, repo_name = *extract_repo_info(topic.url)
        
        # Use repo name if GitHub call fails
        begin
          repo = Octopi::User.find(username).repository(repo_name)
          topic.name        = repo.name[0..250]
          topic.description = repo.description
        rescue Exception
          topic.name = repo_name[0..250]
          topic.description = ''
        end
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