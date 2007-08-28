$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'spec/runner'

require 'bytecode_converter'

describe BytecodeConverter, 'in regard to strings' do
  it 'should convert "hello" to bytecode' do
    BytecodeConverter.convert('hello').should == '0068656C6C6F00'
  end
  
  it 'should convert "goodbye" to bytecode' do
    BytecodeConverter.convert('goodbye').should == '00676F6F6462796500'
  end

  it 'should convert "" to bytecode' do
    BytecodeConverter.convert('').should == '0000'
  end
end

describe BytecodeConverter, 'in regard to integers' do
	it 'should convert "0" to bytecode' do
	  BytecodeConverter.convert(0).should == '0700000000'
	end
	
	it 'should convert "1" to bytecode' do
	  BytecodeConverter.convert(1).should == '0701000000'
	end
	
	it 'should convert "900" to bytecode' do
    BytecodeConverter.convert(900).should == '0784030000'
  end

	it 'should convert "16711680" to bytecode' do
    BytecodeConverter.convert(16711680).should == '070000FF00'
  end

  it 'should convert "4294967295" to bytecode' do
    BytecodeConverter.convert(4294967295).should == '07FFFFFFFF'
  end
end

describe BytecodeConverter, 'in regard to floats' do
	it 'should convert "-0.123456789" to bytecode' do
	  BytecodeConverter.convert(-0.123456789).should == '06DD9ABFBF5F633937'
	end
	
	it 'should convert "1.2" to bytecode' do
		BytecodeConverter.convert(1.2).should == '063333F33F33333333'
	end
end

describe BytecodeConverter, 'in regard to arrays' do
	it 'should convert "[1, 2, 3]" to bytecode' do
    BytecodeConverter.convert([1, 2, 3]).should == '961400070300000007020000000701000000070300000042'
  end
	
	it %q{should convert "['one', 'two', 'three']" to bytecode} do
    BytecodeConverter.convert(['one', 'two', 'three']).should == '961600007468726565000074776F00006F6E6500070300000042'
  end
	
	it %q{should convert "[1, 'two', 3.5]" to bytecode} do
    BytecodeConverter.convert([1, 'two', 3.5]).should == '9618000600000C40000000000074776F000701000000070300000042'
  end
	
	it %q{should convert "[1, ['two', 3.5]]" to bytecode} do
    BytecodeConverter.convert([1, ['two', 3.5]]).should == '9613000600000C40000000000074776F00070200000042960A000701000000070200000042'
  end

	it %q{should convert "[[1], 'two', 3.5]" to bytecode} do
    BytecodeConverter.convert([[1], 'two', 3.5]).should == '960E000600000C40000000000074776F00960A000701000000070100000042960500070300000042'
  end
end

describe BytecodeConverter, 'in regard to booleans' do
	it 'should convert "true" to bytecode' do
    BytecodeConverter.convert(true).should == '0501'
  end
  
  it 'should convert "false" to bytecode' do
    BytecodeConverter.convert(false).should == '0500'
  end
end    

describe BytecodeConverter, 'in regard to nil' do
  it 'should convert "nil" to bytecode' do
   BytecodeConverter.convert(nil).should == '02'
  end
end  
    
describe BytecodeConverter, 'in regard to unhandled datatypes' do
  it 'should raise an exception when asked to convert an unhandled data type' do
    lambda { BytecodeConverter.convert(/^what about (me)?$/) }.should raise_error(StandardError)
  end
end  
