$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'spec/runner'

require 'swf_assembler'

describe SwfAssembler do
  before do
    BytecodeConverter.should_receive(:convert).with(1).once.and_return('0701000000')
  end
  
  it 'should assemble 1 to bytecode without debugging and with 0 compression' do
    SwfAssembler.write_swf(1, false, 0).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_no_debug_no_compression.swx'))
  end

  it 'should assemble 1 to bytecode with debugging and with 0 compression' do
    SwfAssembler.write_swf(1, true, 0).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_with_debug_no_compression.swx'))
  end
  
  it 'should assemble 1 to bytecode without debugging and with compression of 4' # do
  #     SwfAssembler.write_swf(1, false, 4).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_no_debug_compression_4.swx'))
  #   end
  
  it 'should assemble 1 to bytecode with debugging and with compression of 4' # do
  #     SwfAssembler.write_swf(1, true, 4).should == File.read(File.join(File.dirname(__FILE__), 'fixtures', 'number_one_with_debug_compression_4.swx'))
  #   end
end