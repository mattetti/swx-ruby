$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'rubygems'
require 'spec/runner'

require 'swx_gateway'

describe 'SwxGateway#init_service_class' do
	it 'should return the class constant for the specified service class' do
		result = SwxGateway.init_service_class('SwxCheese')
		result.should be(SwxCheese)
	end
end

describe 'SwxGateway#json_to_ruby' do
  it 'should convert a JSON string to a native Ruby object' do
    SwxGateway.json_to_ruby(%q([1,2,{"a":3.141},false,true,null,"4..10"])).should == [1, 2, {"a"=>3.141}, false, true, nil, "4..10"]
  end
end

describe 'SwxGateway#process' do
	it 'should process a hash of params and call SwxAssembler#write_swf with them' do
		cheesy_response = [{:id => '1'}, {:id => '2'}]
		
		swx_cheese = mock(SwxCheese)
		swx_cheese.should_receive(:send).with('all_cheeses').and_return(cheesy_response)
		SwxCheese.should_receive(:new).and_return(swx_cheese)
		
		SwxAssembler.should_receive(:write_swf).with(cheesy_response, nil, 4, nil, true)
		
	  SwxGateway.process(:serviceClass => 'SwxCheese', :method => 'all_cheeses')
	end
end