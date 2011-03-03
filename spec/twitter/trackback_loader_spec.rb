require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'spec_helper')

describe Grapevine::Twitter::TrackbackLoader do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    DataMapper.auto_migrate!
    FakeWeb.allow_net_connect = false
    @loader = Grapevine::Twitter::TrackbackLoader.new
    @loader.name = 'my_loader'
    @loader.site = 'github.com'
    @fixtures_dir = File.join(File.dirname(File.expand_path(__FILE__)), '..', 'fixtures')
  end

  after do
      FakeWeb.clean_registry
  end

  def register_topsy_search_uri(filename, options={})
    options = {:page=>1, :perpage=>10, :site=>'github.com'}.merge(options)
    FakeWeb.register_uri(:get, "http://otter.topsy.com/search.json?page=#{options[:page]}&perpage=#{options[:perpage]}&window=realtime&q=#{CGI.escape(options[:site])}", :response => IO.read("#{@fixtures_dir}/topsy/search/#{filename}"))
  end


  ##############################################################################
  # Tests
  ##############################################################################

  #####################################
  # Loading
  #####################################

  it 'should error when loading without site defined' do
    @loader.site = nil
    lambda {@loader.load()}.should raise_error('Cannot load trackbacks without a site defined')
  end

  it 'should return a single trackback' do
    FakeWeb.register_uri(:get, "https://github.com/tomwaddington/suggestedshare/commit/1e4117f001d224cd15039ff030bc39b105f24a13", :body => '<html><title>tomwaddington/suggestedshare - GitHub</title></html>')
    register_topsy_search_uri('site_github_single')
    
    @loader.load()
    
    messages = Grapevine::Message.all
    messages.length.should == 1
    message = *messages
    message.source.should    == 'my_loader'
    message.source_id.should == '23909517578211328'
    message.author.should    == 'coplusk'
    message.url.should       == 'https://github.com/tomwaddington/suggestedshare/commit/1e4117f001d224cd15039ff030bc39b105f24a13'
    message.content.should   == '[suggestedshare] http://bit.ly/dEeDxh Tom Waddington - caching'
  end

  it 'should page search results' do
    FakeWeb.register_uri(:get, "https://github.com/tomwaddington/suggestedshare/commit/1e4117f001d224cd15039ff030bc39b105f24a13", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/austintimeexchange/oscurrency/commit/35f06c911f2c9b521e24bf73f936b8c783d52e17", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/batterseapower/concurrency-test", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/daneharrigan/like_a_boss", :body => '')
    register_topsy_search_uri('site_github_page1', :page => 1, :perpage => 2)
    register_topsy_search_uri('site_github_page2', :page => 2, :perpage => 2)
    
    @loader.per_page = 2
    @loader.load()
    
    Grapevine::Message.all.length.should == 4
  end

  it 'should not load messages that have already been loaded' do
    FakeWeb.register_uri(:get, "https://github.com/tomwaddington/suggestedshare/commit/1e4117f001d224cd15039ff030bc39b105f24a13", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/austintimeexchange/oscurrency/commit/35f06c911f2c9b521e24bf73f936b8c783d52e17", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/batterseapower/concurrency-test", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/daneharrigan/like_a_boss", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/mangos/one/commit/ee572c8ee639a13bdf9d81d7e451c94e0cb1baa7", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/mongodb/mongo/commit/bcb127567ddd8690ec1897a34c3fb81f27866b6b", :body => '')
    FakeWeb.register_uri(:get, "https://github.com/marak/session.js", :body => '')
    register_topsy_search_uri('site_github')
    @loader.load()
    Grapevine::Message.all.length.should == 7

    register_topsy_search_uri('site_github_later')
    @loader.load()
    Grapevine::Message.all.length.should == 9
  end


  #####################################
  # Aggregation
  #####################################

  it 'should create topic from message' do
    register_topsy_search_uri('site_stackoverflow_single', :site => 'stackoverflow.com')
    FakeWeb.register_uri(:get, "http://stackoverflow.com/questions/4663725/iphone-keyboard-with-ok-button-to-dismiss-with-return-key-accepted-in-the-uite", :response => IO.read("#{@fixtures_dir}/stackoverflow/4663725"))
    @loader.site = 'stackoverflow.com'
    @loader.load()
    
    topics = Grapevine::Topic.all
    topics.length.should == 1
    topic = *topics
    topic.source.should == 'my_loader'
    topic.name.should == 'iPhone - keyboard with OK button to dismiss, with return key accepted in the UITextView - Stack Overflow'
    topic.url.should == 'http://stackoverflow.com/questions/4663725/iphone-keyboard-with-ok-button-to-dismiss-with-return-key-accepted-in-the-uite'
  end
end
