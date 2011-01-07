require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'spec_helper')

describe Grapevine::TwitterGitHubLoader do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    DataMapper.auto_migrate!
    FakeWeb.allow_net_connect = false
    @loader = Grapevine::TwitterGitHubLoader.new
    @fixtures_dir = File.join(File.dirname(File.expand_path(__FILE__)), '..', 'fixtures')
  end

  after do
      FakeWeb.clean_registry
  end

  def register_topsy_search_uri(filename, page=1)
    FakeWeb.register_uri(:get, "http://otter.topsy.com/search.json?page=#{page}&perpage=100&window=h&q=site%3Agithub.com", :response => IO.read("#{@fixtures_dir}/topsy/search/#{filename}"))
  end
  
  def register_topsy_trackback_uri(url, filename, page=1)
    FakeWeb.register_uri(:get, "http://otter.topsy.com/trackbacks.json?perpage=100&window=hour&url=#{CGI.escape(url)}&page=#{page}", :response => IO.read("#{@fixtures_dir}/topsy/trackbacks/#{filename}"))
  end
  
  def register_github_uri(username, repo_name)
    FakeWeb.register_uri(:get, "https://github.com/api/v2/yaml/user/show/#{username}?", :response => IO.read("#{@fixtures_dir}/github/users/#{username}"))
    FakeWeb.register_uri(:get, "https://github.com/api/v2/yaml/repos/show/#{username}/#{repo_name}?", :response => IO.read("#{@fixtures_dir}/github/repos/#{username}_#{repo_name}"))
    FakeWeb.register_uri(:get, "https://github.com/api/v2/yaml/repos/show/#{username}/#{repo_name}/languages?", :response => IO.read("#{@fixtures_dir}/github/repos/languages/#{username}_#{repo_name}"))
  end
  

  ##############################################################################
  # Tests
  ##############################################################################

  it 'should add topic' do
    register_topsy_search_uri('site_github_single')
    register_topsy_trackback_uri('https://github.com/ginatrapani/ThinkUp/wiki/Installing-ThinkUp-on-Amazon-EC2', 'ginatrapani_ThinkUp')
    register_github_uri('ginatrapani', 'ThinkUp')
    
    @loader.load()
  
    topic = Grapevine::Topic.first
    topic.name.should == 'ThinkUp'
    topic.url.should == 'https://github.com/ginatrapani/ThinkUp'
  end

  it 'should tag topic with languages' do
    register_topsy_search_uri('site_github_single')
    register_topsy_trackback_uri('https://github.com/ginatrapani/ThinkUp/wiki/Installing-ThinkUp-on-Amazon-EC2', 'ginatrapani_ThinkUp')
    register_github_uri('ginatrapani', 'ThinkUp')
    
    @loader.load()
  
    Grapevine::Topic.all.length.should == 1
    topic = Grapevine::Topic.first
    topic.tag_list.join(', ').should == 'language_php, language_python'
  end

  it 'should add message' do
    register_topsy_search_uri('site_github_single')
    register_topsy_trackback_uri('https://github.com/ginatrapani/ThinkUp/wiki/Installing-ThinkUp-on-Amazon-EC2', 'ginatrapani_ThinkUp')
    register_github_uri('ginatrapani', 'ThinkUp')
    
    @loader.load()
  
    Grapevine::Message.all.length.should == 3
    message = Grapevine::Message.first
    message.topic.name.should == 'ThinkUp'
    message.source_id.should == '23031898938802176'
    message.author.should == 'vivaceuk'
    message.created_at.to_s.should == '2011-01-06T08:03:27-07:00'
  end

  it 'should ignore non-project links on GitHub' do
    register_topsy_search_uri('site_github_nonproject')
    @loader.load()
    Grapevine::Topic.all().length.should == 0
  end
end
