module Grapevine
  class TwitterGitHubLoader
    ############################################################################
    # Public Methods
    ############################################################################

    # Loads a list of Twitter messages that contain links to GitHub projects or
    # files within those projects.
    def load()
      perpage = 100
      page = 1
      total = 999999
      
      # Loop over pages
      while (page-1) * perpage < total
        # Search for Twitter messages with GitHub links
        results = Topsy.search(:site => 'github.com', :window => :hour, :page => page, :perpage => perpage)
        perpage = results.perpage
        total   = results.total
        
        # Loop over links and load trackbacks for each one
        results.list.each do |item|
          load_trackbacks(item.url)
        end

        page += 1
      end
    end
    

    ############################################################################
    # Private Methods
    ############################################################################

    private
    
    def load_trackbacks(url)
      # Find the topic if it already exists
      topic = find_or_create_topic(url)
      return if topic.nil?
      
      # Loop over trackback pages until we get repeats or we go too far back
      perpage = 100
      page = 1
      total = 999999
      
      while (page-1) * perpage < total
        # Find trackbacks
        results = Topsy.trackbacks(url, :window => :hour, :page => page, :perpage => perpage)
        total = results.total
        
        results.list.each do |item|
          # Find message by Twitter status id
          m, source_id = *item.permalink_url.match(/(\d+)$/)
          
          # Stop saving trackbacks if we have repeats
          return if Grapevine::Message.first(:source_id => source_id)
          
          # Create message
          Grapevine::Message.create(
            :topic      => topic,
            :source_id  => source_id,
            :author     => item.author.nick,
            :created_at => Time.at(item.date)
          )
        end
      end
    end
      
    # Retrieves an existing topic or creates a new one if it doesn't exist
    def find_or_create_topic(url)
      # Retrieve GitHub username and repo
      username, repo_name = *extract_repo_info(url)
      return if username.nil?
      
      # Construct topic URL
      url = "https://github.com/#{username}/#{repo_name}"
      
      # Retrieve topic if it exists
      topic = Topic.first(:url => url)
      
      # Retrieve GitHub information
      repo = get_repository(username, repo_name)
      return nil if repo.nil?
      
      # Otherwise create a new one
      if topic.nil?
        topic = Topic.new(
          :source => 'twitter-github',
          :name   => repo_name,
          :url    => url
        )
      end
      
      # Update topic tags
      tags = []
      tags = tags.concat(get_repository_languages(repo).map {|v| "language_#{v}"})
      topic.tag_list = tags.join(', ')
      
      # Save topic
      topic.save
      
      return topic
    end

    # Parses a GitHub URL and extracts repo information
    def extract_repo_info(url)
      m, username, repo_name = *url.match(/^https?:\/\/(?:www.)?github.com\/([^\/]+)\/([^\/]+)/i)
      return (m ? [username, repo_name] : nil)
    end
    
    # Retrieves a repository from GitHub given a username and repository name.
    def get_repository(username, repo_name)
      Octopi::User.find(username).repository(repo_name)
    end

    # Retrieves a list of primary languages used in a repository
    def get_repository_languages(repo)
      lookup = repo.languages
      total = lookup.values.inject(0) {|s,v| s += v}
      
      # Find languages that are at least 20 percent of the project
      languages = []
      lookup.each_pair do |k,v|
        k = k.downcase.gsub(/\s+/, '-')
        languages << k if v >= total*0.2
      end
      
      return languages
    end
  end
end