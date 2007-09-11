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
	
rescue Exception => e
  puts 'ERROR INSTALLING rSWX: ' + e.message
end