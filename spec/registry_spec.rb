require File.join(File.dirname(File.expand_path(__FILE__)), 'spec_helper')

describe Grapevine::Registry do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    @registry = Grapevine::Registry.new()
  end

  after do
    @registry = nil
  end


  ##############################################################################
  # Tests
  ##############################################################################

  #####################################
  # Loaders
  #####################################

  it 'should add loader to registry' do
    loader = Grapevine::Loader.new()
    @registry.add_loader(loader)
    @registry.loaders.index(loader).should_not be_nil
  end

  it 'should remove loader from registry' do
    loader = Grapevine::Loader.new()
    @registry.add_loader(loader)
    @registry.remove_loader(loader)
    @registry.loaders.length.should == 0
  end


  #####################################
  # Notifiers
  #####################################

  it 'should add notifier to registry' do
    notifier = Grapevine::Notifier.new()
    @registry.add_notifier(notifier)
    @registry.notifiers.index(notifier).should_not be_nil
  end

  it 'should remove notifier from registry' do
    notifier = Grapevine::Notifier.new()
    @registry.add_notifier(notifier)
    @registry.remove_notifier(notifier)
    @registry.notifiers.length.should == 0
  end


  #####################################
  # Config
  #####################################

  it 'should create loaders from configuration file' do
    IO.expects(:read).with('/tmp/grapevine.yml').returns(
      <<-BLOCK.unindent
      sources:
        - name: my-loader-1
          type: twitter-github
          frequency: 1m
        - name: my-loader-2
          type: twitter-trackback
          frequency: 2h
      BLOCK
    )
    @registry.load_config('/tmp/grapevine.yml')
    @registry.loaders.length.should == 2
    loader1, loader2 = *@registry.loaders
    loader1.class.should == Grapevine::Twitter::GitHubTrackbackLoader
    loader1.name.should == 'my-loader-1'
    loader1.frequency.should == 60
    loader2.class.should == Grapevine::Twitter::TrackbackLoader
    loader2.name.should == 'my-loader-2'
    loader2.frequency.should == 7_200
  end

  it 'should create notifiers from configuration file' do
    IO.expects(:read).with('/tmp/grapevine.yml').returns(
      <<-BLOCK.unindent
      notifiers:
        - name: my-notifier
          type: twitter
          username: test_notifier
          oauth_token: foo
          oauth_token_secret: bar
          source: my-loader
          frequency: 8h
          tags: [language:javascript, language:html]
      BLOCK
    )
    @registry.load_config('/tmp/grapevine.yml')
    @registry.notifiers.length.should == 1
    notifier = *@registry.notifiers
    notifier.class.should == Grapevine::Twitter::TweetNotifier
    notifier.name.should == 'my-notifier'
    notifier.username.should == 'test_notifier'
    notifier.oauth_token.should == 'foo'
    notifier.oauth_token_secret.should == 'bar'
    notifier.source.should == 'my-loader'
    notifier.frequency.should == 28_800
    notifier.tags.length.should == 2
  end
end
