$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'spec/runner'

require 'core_extensions'

class MyClass
	def initialize
		@foo = 'foo'
		@bar = 'bar'
	end
end

describe 'Object extensions' do
  it '#instance_values should convert an object\'s instance variables to a hash' do
    MyClass.new.instance_values.should be_an_instance_of(Hash)
    MyClass.new.instance_values.sort_by { |key, value| value }.should == [['bar', 'bar'], ['foo', 'foo']]
  end
end

describe 'hash extension' do
  it 'should convert a symbol keyed hash into a string keyed hash' do
    {:this => 'this', :is => 'is', :test => 'test', :number => 0}.stringify_keys.should == {'this' => 'this', 'is' => 'is', 'test' => 'test', 'number' => 0}
  end
  
  
end