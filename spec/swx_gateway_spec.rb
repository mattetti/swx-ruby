$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib', 'services')
require 'rubygems'
require 'spec/runner'

require 'swx_gateway'

module SwxGatewaySpecHelper
	def configure_swx_gateway
		SwxGateway.app_root = './'
		SwxGateway.swx_config = {
			'services_path' 		 => File.join('./', 'lib', 'services'), 
			'allow_domain' 		 => true, 
			'compression_level' => 4
		}
	end
end

describe 'SwxGateway#init_service_class' do
	include SwxGatewaySpecHelper
	
	before do
	  configure_swx_gateway
	end
	
	it 'should initialize all of the service classes in the service classes folder' do
		SwxGateway.init_service_classes
		lambda { SwxServiceClasses::HelloWorld }.should_not raise_error(NameError)
		lambda { SwxServiceClasses::TestDataTypes }.should_not raise_error(NameError)
	end
end

describe 'SwxGateway#json_to_ruby' do
	include SwxGatewaySpecHelper
	
	before do
	  configure_swx_gateway
	end
	
  it 'should convert a JSON string to a native Ruby object' do
    SwxGateway.json_to_ruby(%q([1,2,{"a":3.141},false,true,null,"4..10"])).should == [1, 2, {"a"=>3.141}, false, true, nil, "4..10"]
  end
end

describe 'SwxGateway#process' do
	include SwxGatewaySpecHelper
	
	before do
	  configure_swx_gateway
	end
	
	it 'should process a hash of params and call SwxAssembler#write_swf with them' do
		require 'hello_world'
		swx_service_classes = mock(SwxServiceClasses)
		hello_world = mock(SwxServiceClasses::HelloWorld)
		
		hello_world.should_receive(:send).with('just_say_the_words').and_return('Hello World!')
		SwxServiceClasses::HelloWorld.should_receive(:new).and_return(hello_world)
		
		SwxAssembler.should_receive(:write_swf).with('Hello World!', nil, 4, nil, true)
		
	  SwxGateway.process(:serviceClass => 'HelloWorld', :method => 'justSayTheWords')
	end
end