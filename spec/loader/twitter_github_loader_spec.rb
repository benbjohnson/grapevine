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

  def register_topsy_search_uri(filename, options={})
    options = {:page=>1, :perpage=>100}.merge(options)
    FakeWeb.register_uri(:get, "http://otter.topsy.com/search.json?page=#{options[:page]}&perpage=#{options[:perpage]}&window=h&q=site%3Agithub.com", :response => IO.read("#{@fixtures_dir}/topsy/search/#{filename}"))
  end
  
  def register_topsy_trackback_uri(url, filename, options={})
    options = {:page=>1, :perpage=>100}.merge(options)
    FakeWeb.register_uri(:get, "http://otter.topsy.com/trackbacks.json?perpage=#{options[:perpage]}&window=hour&url=#{CGI.escape(url)}&page=#{options[:page]}", :response => IO.read("#{@fixtures_dir}/topsy/trackbacks/#{filename}"))
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

  it 'should support search paging' do
    register_topsy_search_uri('site_github_page1', :page => 1)
    register_topsy_search_uri('site_github_page2', :page => 2, :perpage => 2)
    register_topsy_trackback_uri('https://github.com/ginatrapani/ThinkUp/wiki/Installing-ThinkUp-on-Amazon-EC2', 'ginatrapani_ThinkUp')
    register_topsy_trackback_uri('https://github.com/basho/riak/raw/riak-0.14.0/releasenotes/riak-0.14.0.txt', 'basho_riak')
    register_github_uri('basho', 'riak')
    register_github_uri('ginatrapani', 'ThinkUp')
    
    @loader.load()
  
    Grapevine::Topic.all.length.should == 2
    Grapevine::Topic.first(:name => 'ThinkUp').should_not be_nil
    Grapevine::Topic.first(:name => 'riak').should_not be_nil
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

  it 'should support trackback paging' do
    register_topsy_search_uri('site_github_single')
    register_topsy_trackback_uri('https://github.com/ginatrapani/ThinkUp/wiki/Installing-ThinkUp-on-Amazon-EC2', 'ginatrapani_ThinkUp_page1', :page => 1)
    register_topsy_trackback_uri('https://github.com/ginatrapani/ThinkUp/wiki/Installing-ThinkUp-on-Amazon-EC2', 'ginatrapani_ThinkUp_page2', :page => 2, :perpage => 2)
    register_github_uri('ginatrapani', 'ThinkUp')
    
    @loader.load()
  
    Grapevine::Message.all.length.should == 3
    Grapevine::Message.all(:source_id => '23031898938802176').length.should == 1
    Grapevine::Message.all(:source_id => '22955482826145792').length.should == 1
    Grapevine::Message.all(:source_id => '22935307057889280').length.should == 1
  end

  it 'should ignore non-project links on GitHub' do
    register_topsy_search_uri('site_github_nonproject')
    @loader.load()
    Grapevine::Topic.all().length.should == 0
  end
end
