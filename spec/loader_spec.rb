require File.join(File.dirname(File.expand_path(__FILE__)), 'spec_helper')

describe Grapevine::Loader do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    @loader = Grapevine::Loader.new()
  end

  after do
    @loader = nil
  end


  ##############################################################################
  # Tests
  ##############################################################################

  #####################################
  # Static methods
  #####################################

  it 'should create a loader' do
    loader = Grapevine::Loader.create(
      'twitter-github',
      :name => 'foo',
      :frequency => '5m'
    )
    loader.class.should == Grapevine::Twitter::GitHubTrackbackLoader
    loader.name.should == 'foo'
    loader.frequency.should == 300
  end
end
