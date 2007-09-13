$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'spec/runner'

require 'active_record'
require 'bytecode_converter'
require 'date'

describe BytecodeConverter, 'in regard to arrays' do
  it 'should convert "[1, 2, 3]" to bytecode' do
      BytecodeConverter.convert([1, 2, 3]).should == '961400070300000007020000000701000000070300000042'
    end
  
  it %q(should convert "['one', 'two', 'three']" to bytecode) do
    BytecodeConverter.convert(['one', 'two', 'three']).should == '961600007468726565000074776F00006F6E6500070300000042'
  end
  
     it %q(should convert "[1, 'two', 3.5]" to bytecode) do
      BytecodeConverter.convert([1, 'two', 3.5]).should == '9618000600000C40000000000074776F000701000000070300000042'
    end
     
    it %q(should convert "[1, ['two', 3.5]]" to bytecode) do
      BytecodeConverter.convert([1, ['two', 3.5]]).should == '9613000600000C40000000000074776F00070200000042960A000701000000070200000042'
    end
  
  it %q(should convert "[[1], 'two', 3.5]" to bytecode) do
    BytecodeConverter.convert([[1], 'two', 3.5]).should == '960E000600000C40000000000074776F00960A000701000000070100000042960500070300000042'
  end
   
   it %q(should convert "[1, {'number' => 2}, 3]") do
     BytecodeConverter.convert([1, {'number' => 2}, 3]).should == '9605000703000000961200006E756D626572000702000000070100000043960A000701000000070300000042'
   end
     
   it %q(should convert "[1, {'numbers' => [{'two' => 2}, {'three' => 3}]}, 4]") do
     BytecodeConverter.convert([1, {'numbers' => [{'two' => 2}, {'three' => 3}]}, 4]).should == '9605000704000000960900006E756D6265727300961100007468726565000703000000070100000043960F000074776F000702000000070100000043960500070200000042960500070100000043960A000701000000070300000042'
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

describe BytecodeConverter, 'in regard to custom classes' do
  it 'should convert the class to a hash by calling CustomClass#instance_values' do
		@custom_class = mock('MyCustomClass')
		# BytecodeConverter.should_receive(:convert).with(@custom_class)
		@custom_class.should_receive(:instance_values).and_return({'it' => 'works'})
		# BytecodeConverter.should_receive(:convert).with({'it' => 'works'})
		
    BytecodeConverter.convert(@custom_class)
  end
end

describe BytecodeConverter, 'in regard to datetimes' do
  it 'should convert a datetime to a string and pass it to BytecodeConverter#string_to_bytecode' do
    BytecodeConverter.should_receive(:string_to_bytecode).with('Sunday September 09, 2007 at 12:30 PM')
		BytecodeConverter.convert(DateTime.new(2007, 9, 9, 12, 30))
  end
end

describe BytecodeConverter, 'in regard to dates' do
  it 'should convert a date to a string and pass it to BytecodeConverter#string_to_bytecode' do
		BytecodeConverter.should_receive(:string_to_bytecode).with('Sunday September 09, 2007')
		BytecodeConverter.convert(Date.new(2007, 9, 9))
  end
end

describe BytecodeConverter, 'in regard to floats' do
	it 'should convert "-0.123456789" to bytecode' do
	  BytecodeConverter.convert(-0.123456789).should == '06DD9ABFBF5F633937'
	end
	
	it 'should convert "1.2" to bytecode' do
		BytecodeConverter.convert(1.2).should == '063333F33F33333333'
	end
	
	it 'should convert "42.12345" to bytecode' do
	  BytecodeConverter.convert(42.12345).should == '06CD0F45407958A835'
	end
end

describe BytecodeConverter, 'in regard to hashes' do
  it %q[should convert {'it' => 'works', 'number' => 42} to bytecode] do
    BytecodeConverter.convert({'it' => 'works', 'number' => 42}).should == '961D00006E756D62657200072A0000000069740000776F726B7300070200000043'
  end

  it %q[should convert {'numbers' => [1]} to bytecode] do
    BytecodeConverter.convert({'numbers' => [1]}).should == '960900006E756D6265727300960A000701000000070100000042960500070100000043'
  end
  
  it %q[should convert {'they' => ['really', 'work'], 'numbers' => [1, 2, 3]} to bytecode] do
    BytecodeConverter.convert({'they' => ['really', 'work'], 'numbers' => [1, 2, 3]}).should == '960900006E756D626572730096140007030000000702000000070100000007030000004296060000746865790096130000776F726B00007265616C6C7900070200000042960500070200000043'
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

describe BytecodeConverter, 'in regard to nil' do
  it 'should convert "nil" to bytecode' do
   BytecodeConverter.convert(nil).should == '02'
  end
end

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
    
describe BytecodeConverter, 'in regard to unhandled datatypes' do
  it 'should raise an exception when asked to convert an unhandled data type' do
    lambda { BytecodeConverter.convert(/^What about (me)?$/) }.should raise_error(StandardError)
  end
end  
