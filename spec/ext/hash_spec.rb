require File.join(File.dirname(File.expand_path(__FILE__)), '../spec_helper')

describe Hash do
  ##############################################################################
  # Tests
  ##############################################################################

  it 'should convert all string keys to symbols' do
    hash = {'foo' => 1, 'bar' => 2, :baz => 3}
    hash = hash.symbolize
    hash.key?('foo').should == false
    hash.key?(:foo).should == true
    hash.key?('bar').should == false
    hash.key?(:bar).should == true
    hash.key?('baz').should == false
    hash.key?(:baz).should == true
  end
end
