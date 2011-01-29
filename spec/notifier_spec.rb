require File.join(File.dirname(File.expand_path(__FILE__)), 'spec_helper')

describe Grapevine::Notifier do
  ##############################################################################
  # Setup
  ##############################################################################

  before do
    DataMapper.auto_migrate!
    create_data()
    @notifier = Grapevine::Notifier.new('notifier')
  end

  after do
    @notifier = nil
  end


  def create_data()
    @t0 = create_topic('foo')
    @t1 = create_topic('bar')
    
    @m0_0 = create_message(@t0)
    @m0_1 = create_message(@t0)
    @m1_0 = create_message(@t1)
    @m1_1 = create_message(@t1)
    @m1_2 = create_message(@t1)
  end

  def create_topic(name)
    Grapevine::Topic.create(:source => 'twitter-github', :name => 'foo', :created_at => Time.now)
  end

  def create_message(topic)
    Grapevine::Message.create(:topic => topic)
  end

  def create_tag(topic, type, value)
    Grapevine::Tag.create(:topic => topic, :type => type, :value => value)
  end

  def create_notification(topic, source, created_at)
    Grapevine::Notification.create(:topic => topic, :source => source, :created_at => created_at)
  end


  ##############################################################################
  # Tests
  ##############################################################################

  #####################################
  # Topics
  #####################################

  it 'should return topics in order of popularity' do
    topics = @notifier.popular_topics
    topics.length.should == 2
    topics[0].should == @t1
    topics[1].should == @t0
  end

  it 'should filter out popular topics by notification window' do
    Timecop.freeze(Time.local(2010, 1, 8)) do
      create_notification(@t0, 'notifier', Time.local(2010, 1, 1))
      create_notification(@t1, 'notifier', Time.local(2010, 1, 4))
    
      @notifier.window = 84600 * 7   # 1 week
      topics = @notifier.popular_topics
      topics.length.should == 1
      topics[0].should == @t0
    end
  end

  it 'should filter out popular topics by tag' do
    create_tag(@t0, 'language', 'ruby')
    create_tag(@t0, 'language', 'javascript')
    create_tag(@t1, 'language', 'ruby')

    @notifier.tags = Grapevine::Tag.all(:type => 'language', :value => 'javascript')
    topics = @notifier.popular_topics
    topics.length.should == 1
    topics[0].should == @t0
  end
end
