require 'json'
require 'swx_assembler'

class SwxGateway
  class << self
		attr_accessor :app_root, :swx_config
		
		def init_service_classes #:nodoc:
			puts "# ===============================
			# = init_service_classes called =
			# ==============================="
			Dir.glob(File.join(app_root, swx_config['services_path'], './**/*.rb'))	{ |filename| require filename }
			true
		end
		
		# The entry point for SWX request processing. Takes a hash of +params+ and goes to work generating SWX bytecode. 
    # 
		# Special note: Contrary to Ruby convention, keys in the +params+ hash are camelCase (instead of underscored). This 
		# is to maintain compatibility with the SWX AS library which sends request parameters 
		# using camelCase (ActionScript's variable naming convention).
    # 
		# ==== Params
		# * <tt>:args</tt> --  JSON string of arguments (converted to a Ruby object and passed to the specified method of the service class)
		# * <tt>:debug</tt> -- Boolean. If set to true, the generated SWX file will attempt to establish a local connection the SWX Analyzer when opened in Flash Player.
		# * <tt>:method</tt> --  specifies the method to be called on the service class. May be either camelCased or underscored (camelCased will be converted to underscored before being called on the service class)
		# * <tt>:serviceClass</tt> -- specifies the service class 
		# * <tt>:url</tt> -- (optional) the url of the SWF file making this request. Added to the generated SWX file to skirt cross-domain issues. If not specified, the resulting SWX file allow access from any domain
    # 
		# ==== Examples
	  # SwxGateway.process(:args => 'Hello World!', :debug => true, :method => 'echo_data', :serviceClass => 'Simple', :url => 'http://myfunkysite/swxconsumer.swf')
	  # # => A binary string of SWX bytecode containing the result of +Simple.new#echo_data('Hello World!')+; debugging enabled and allowing access from the specified url
    # 
	  # SwxGateway.process(:args => 'Hello World!', :debug => true, :method => 'echo_data', :serviceClass => 'Simple')
	  # # => Same as previous, except allows access from any url
    # 
	  # SwxGateway.process(:args => [1,2], :debug => false, :method => 'addNumbers', :serviceClass => 'Simple', :url => 'http://myfunkysite/swxconsumer.swf')
	  # # calls params[:method].underscore
	  # # => A binary string of SWX bytecode containing the result of +Simple.new#add_numbers(1, 2)+; no debugging and allowing access from the specified url
    def process(params)
			# Call init_service_classes the first time SwxGateway#process is called
			@service_classes_initialized ||= init_service_classes
			
			# Fetch the class contant for the specified service class
      service_class = params[:serviceClass].constantize

			# convert camelCased params[:method] to underscored (does nothing if params[:method] is already underscored)
			params[:method] = params[:method].underscore

			# convert JSON arguments to a Ruby object
			args = json_to_ruby params[:args]
			
			# ================================================================================
			# = TODO: Exception handling if specified method does not exist in service class =
			# ================================================================================
      # Instantiate the service class, call the specified method, and capture the response
			service_class_response = if args.nil?
				# No args were passed, so assume the service class' method doesn't take any arguments
	      service_class.new.send(params[:method])
			else
				# Call the service class' method and pass in the arguments (uses an * to pass an array as multiple arguments)
	      service_class.new.send(params[:method], *json_to_ruby(params[:args]))
			end
        
      # assemble and return swx file 
			SwxAssembler.write_swf(service_class_response, params[:debug], swx_config['compression_level'], params[:url], swx_config['allow_domain'])
    end
    
    def json_to_ruby(arguments) #:nodoc:
      JSON.parse arguments unless arguments.nil? || arguments.empty?
    end
  end
end