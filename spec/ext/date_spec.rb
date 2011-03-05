require File.join(File.dirname(File.expand_path(__FILE__)), '../spec_helper')

describe Date do
  ##############################################################################
  # Tests
  ##############################################################################

  it 'should parse a time period in seconds' do
    Date.parse_time_period('200s').should == 200
  end

  it 'should parse a time period in minutes' do
    Date.parse_time_period('5m').should == 300
  end

  it 'should parse a time period in hours' do
    Date.parse_time_period('3h').should == 10_800
  end

  it 'should parse a time period in days' do
    Date.parse_time_period('2d').should == 172_800
  end

  it 'should parse a time period in weeks' do
    Date.parse_time_period('4w').should == 2_419_200
  end

  it 'should parse a time period in months' do
    Date.parse_time_period('3M').should == 7_776_000
  end

  it 'should parse a time period in years' do
    Date.parse_time_period('4y').should == 126_144_000
  end

  it 'should parse a compound time period' do
    Date.parse_time_period('1y2M3w4d5h6m7s').should == 38_898_367
  end

  it 'should return nil when parsing invalid format' do
    Date.parse_time_period('foo bar').should be_nil
  end

  it 'should return nil when parsing invalid time period' do
    Date.parse_time_period('12i').should be_nil
  end
end
