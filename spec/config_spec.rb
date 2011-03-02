require File.join(File.dirname(File.expand_path(__FILE__)), 'spec_helper')

describe Grapevine::Config do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    @config = Grapevine::Config.new
  end

  after do
    @config = nil
  end


  ##############################################################################
  # Tests
  ##############################################################################

  #####################################
  # Topics
  #####################################

  it 'should set configuration with a hash' do
    hash = {:bitly_username => 'foo', 'bitly_api_key' => 'bar', :no_such_key => ''}
    @config.load(hash)
    @config.bitly_username.should == 'foo'
    @config.bitly_api_key.should == 'bar'
  end

  it 'should load configuration from a file' do
    filename = File.join(File.dirname(File.expand_path(__FILE__)), 'fixtures', 'config', 'test.yml')
    @config.load_file(filename)
    @config.bitly_username.should == 'foo'
    @config.bitly_api_key.should == 'bar'
  end

  it 'should set singleton configuration options' do
    Grapevine::Config.bitly_username = 'foo'
    Grapevine::Config.bitly_username.should == 'foo'
  end
end
