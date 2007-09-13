# Taken from Railties
def gsub_file(relative_destination, regexp, *args, &block)
  path = relative_destination
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end

@what_now = <<-INSTRUCTIONS

=======================================
SWX Ruby: SWX on Rails Plugin Alpha 0.1
=======================================

GETTING STARTED
===============
SWX on Rails will look for your service classes in RAILS_ROOT/app/services.
Simply create standard Ruby classes and drop them in this folder. Service classes 
are composed of instance methods. SWX on Rails will instantiate your service
class, call the specified method, and send the response back to the Flash Player.

Take a peek at app/services/hello_world.rb for a working service class example. 
Here's a Moo card-esque example to call HelloWorld#just_say_the_words from the 
Flash Player (place a MovieClip on stage with an instance name of 'loader' and
fire up your development server):

//------------------------------------------------------
loader.serviceClass = "HelloWorld";
loader.method = "just_say_the_words";
loader.debug = true;
loader.loadMovie("http://localhost:3000/swx", "POST");

function onEnterFrame() {
 trace(loader.result);
}
//------------------------------------------------------

When you're ready for some robust ActionScript trickery, head to 
http://swxformat.org/download/ to grab the SWX ActionScript library.

Oh yeah, you may return ActiveRecord objects from your service classes; 
SWX on Rails will happily serialize them for you. Go ahead, give it a try!

SWX on Rails is very alpha and may break, throw its toys, eat your
firstborn child, etc.; please send bug reports/suggestions to 
jedhurt@cableone.net. Full-featured tracker and mailing lists coming soon.
=======================================
NOTE: You may notice some Security Sandbox Violations when testing the example
above in the Flash IDE. Rest assured, this is OK. Visit 
http://swxformat.org/132 for further explanation.


INSTRUCTIONS

begin
  require 'fileutils'
	include FileUtils
  
	# Copy config file
  unless File.exist?('./config/swx.yml')
		puts '*** Copying config file to config/swx.yml ***'
    cp('./vendor/plugins/swx_on_rails/lib/config/swx.yml', './config/swx.yml')
  end
  
	# Copy SWX controller
	unless File.exist?('./app/controllers/swx_controller.rb')
		puts '*** Copying SWX controller to app/controllers/swx_controller.rb ***'
	  cp('./vendor/plugins/swx_on_rails/lib/controllers/swx_controller.rb','./app/controllers/swx_controller.rb')
	end
	
	# Create services directory
	unless File.exist?('./app/services')
		puts '*** Creating services directory at app/services ***'
		mkdir('./app/services')
	end
	
	# Copy TestDataTypes class to app/services
	unless File.exist?('./app/services/test_data_types.rb')
		puts '*** Copying TestDataTypes service class to app/services ***'
		cp('./vendor/plugins/swx_on_rails/lib/services/test_data_types.rb','./app/services/test_data_types.rb')
	end
	
	# Copy HelloWorld class to app/services
	unless File.exist?('./app/services/hello_world.rb')
		puts '*** Copying HelloWorld service class to app/services ***'
		cp('./vendor/plugins/swx_on_rails/lib/services/hello_world.rb','./app/services/hello_world.rb')
	end
	
	# Add route for SWX gateway to routes.rb
	puts '*** Adding route for SWX gateway to routes.rb ***'
	sentinel = 'ActionController::Routing::Routes.draw do |map|'
	gsub_file './config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
	  "#{match}\n  map.swx '/swx', :controller => 'swx', :action => 'gateway'\n"
	end

	# Check for installation of JSON gem
	print '*** Checking if JSON gem is installed'
	require 'rubygems'
	require 'json'
	puts ': JSON gem detected ***'
	
	puts @what_now
rescue LoadError
	puts @what_now
	
	puts '!!!!! You do not have the JSON gem installed. SWX on Rails will not function without it.'
	puts '!!!!! Please "gem install json" to get the JSON gem, then SWX on Rails should be ready to roll.'
rescue Exception => e
  puts 'ERROR INSTALLING rSWX: ' + e.message
end