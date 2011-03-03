require File.join(File.dirname(File.expand_path(__FILE__)), '..', 'spec_helper')

describe Grapevine::Notifier do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    FakeWeb.allow_net_connect = false
    DataMapper.auto_migrate!
    Grapevine::Config.config = nil
    Grapevine::Config.load({
      'bitly_username' => 'foo',
      'bitly_api_key' => 'bar',
    })
    create_data()
    @notifier = Grapevine::Twitter::TweetNotifier.new()

    @fixtures_dir = File.join(File.dirname(File.expand_path(__FILE__)), '..', 'fixtures')
    FakeWeb.register_uri(:get, "http://api.bit.ly/v3/shorten?login=foo&longUrl=http%3A%2F%2Fgithub.com%2Fbenbjohnson%2Fmockdown&apiKey=bar", :response => IO.read("#{@fixtures_dir}/bitly/mockdown.json"))
  end

  after do
    @notifier = nil
  end

  def create_data()
    @t0 = create_topic('foo', 'http://github.com/benbjohnson/smeagol')
    @t1 = create_topic('bar', 'http://github.com/benbjohnson/mockdown')
    
    Grapevine::Message.create(:topic => @t0)
    Grapevine::Message.create(:topic => @t0)
    Grapevine::Message.create(:topic => @t1)
    Grapevine::Message.create(:topic => @t1)
    Grapevine::Message.create(:topic => @t1)
  end

  def create_topic(name, url)
    Grapevine::Topic.create(:source => 'twitter-github', :name => 'foo', :url => url, :created_at => Time.now)
  end


  ##############################################################################
  # Tests
  ##############################################################################

  #####################################
  # Topics
  #####################################

  it 'should send a tweet for the most popular topic' do
    #FakeWeb.register_uri(:post, "https://api.twitter.com/1/statuses/update.json", :response => IO.read("#{@fixtures_dir}/twitter/statuses/update.json"))
    #@notifier.send()
  end
end
