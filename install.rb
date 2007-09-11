# Taken from Railties
def gsub_file(relative_destination, regexp, *args, &block)
  path = relative_destination
  content = File.read(path).gsub(regexp, *args, &block)
  File.open(path, 'wb') { |file| file.write(content) }
end

begin
  require 'fileutils'
	include FileUtils
  
	# Copy config file
  unless File.exist?('./config/swx.yml')
		puts '*** Copying config file to config/swx.yml ***'
    cp('./vendor/plugins/rswx/lib/config/swx.yml', './config/swx.yml')
  end
  
	# Copy rSWX controller
	unless File.exist?('./app/controllers/swx_controller.rb')
		puts '*** Copying rSWX controller to app/controllers/swx_controller.rb ***'
	  cp('./vendor/plugins/rswx/lib/controllers/swx_controller.rb','./app/controllers/swx_controller.rb')
	end
	
	# Create services directory
	unless File.exist?('./app/services')
		puts '*** Creating services directory at app/services ***'
		mkdir('./app/services')
	end
	
	# Copy TestDataTypes to app/services
	unless File.exist?('./app/services/test_data_types.rb')
		puts '*** Copying TestDataTypes service to app/services ***'
		cp('./vendor/plugins/rswx/lib/services/test_data_types.rb','./app/services/test_data_types.rb')
	end
	
	# Add route for rSWX gateway to routes.rb
	sentinel = 'ActionController::Routing::Routes.draw do |map|'
	gsub_file './config/routes.rb', /(#{Regexp.escape(sentinel)})/mi do |match|
	  "#{match}\n  map.swx '/swx', :controller => 'swx', :action => 'gateway'\n"
	end


rescue Exception => e
  puts 'ERROR INSTALLING rSWX: ' + e.message
end