$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'spec/runner'

require 'swx_gateway'

describe 'SwxGateway#json_to_ruby' do
  it 'should convert a JSON string to a native Ruby object' do
    SwxGateway.json_to_ruby(%q([1,2,{"a":3.141},false,true,null,"4..10"])).should == [1, 2, {"a"=>3.141}, false, true, nil, "4..10"]
  end

	it 'should dynamically load in the specified service class'
	
	it 'should call the method specified in the params on the service class'
end

# describe SwxAssembler do
#   before do
#     BytecodeConverter.should_receive(:convert).with(1).once.and_return('0701000000')
#   end
#   
#   it 'should assemble a swx file without debugging and without compression' do
#     SwxAssembler.write_swf(1, false, 0).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_no_debug_no_compression.swx'))
#   end
#   
#   it 'should assemble a swx file with debugging and without compression' do
#     SwxAssembler.write_swf(1, true, 0).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_with_debug_no_compression.swx'))
#   end
#   
#   it 'should assemble a swx file without debugging and with compression' # do
#   #     SwxAssembler.write_swf(1, false, 4).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_no_debug_compression_4.swx'))
#   #   end
#     
#   it 'should assemble a swx file with debugging and with compression' # do
#   #     SwxAssembler.write_swf(1, true, 4).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_with_debug_compression_4.swx'))
#   #   end
# end