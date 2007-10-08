$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')
$:.unshift File.join(File.dirname(__FILE__), '..', 'lib', 'services')
require 'rubygems'
require 'spec/runner'

require 'discovery_service'

describe DiscoveryService do
  it 'should list all of the available services present in the services path'

	it 'should describe the methods and arguments of a specified service class'
end