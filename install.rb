# Taken from Railties
def gsub_file(relative_destination, regexp, *args, &block)
  path = relative_destination
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end

SWX_RUBY_ROOT = File.dirname(__FILE__)
@getting_started = IO.read(File.join(SWX_RUBY_ROOT, 'README'))

begin
  require 'fileutils'
	include FileUtils
  
	# Copy config file
  unless File.exist?('./config/swx.yml')
		puts '*** Copying config file to config/swx.yml ***'
    cp(File.join(SWX_RUBY_ROOT, 'lib', 'config', 'swx.yml'), './config/swx.yml')
  end
  
	# Copy SWX controller
	unless File.exist?('./app/controllers/swx_controller.rb')
		puts '*** Copying SWX controller to app/controllers/swx_controller.rb ***'
	  cp(File.join(SWX_RUBY_ROOT, 'lib', 'controllers', 'swx_controller.rb'), './app/controllers/swx_controller.rb')
	end
	
	# Create services directory
	unless File.exist?('./app/services')
		puts '*** Creating services directory at app/services ***'
		mkdir('./app/services')
	end
	
	# Copy TestDataTypes class to app/services
	unless File.exist?('./app/services/test_data_types.rb')
		puts '*** Copying TestDataTypes service class to app/services ***'
		cp(File.join(SWX_RUBY_ROOT, 'lib', 'services', 'test_data_types.rb'), './app/services/test_data_types.rb')
	end
	
	# Copy HelloWorld class to app/services
	unless File.exist?('./app/services/hello_world.rb')
		puts '*** Copying HelloWorld service class to app/services ***'
		cp(File.join(SWX_RUBY_ROOT, 'lib', 'services', 'hello_world.rb'), './app/services/hello_world.rb')
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
	
	puts @getting_started
rescue LoadError
	puts @getting_started
	
	puts '!!!!! You do not have the JSON gem installed. SWX on Rails will not function without it.'
	puts '!!!!! Please "gem install json" to get the JSON gem, then SWX on Rails should be ready to roll.'
rescue Exception => e
  puts 'ERROR INSTALLING SWX Ruby: ' + e.message
end