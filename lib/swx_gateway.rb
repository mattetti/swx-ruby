require 'json'
require 'swx_assembler'
require 'yaml'

class SwxGateway
  class << self
		# ====================================================================================
		# = TODO: Make sure that YAML.load_file is only called once instead of every request =
		# ====================================================================================
		SWX_CONFIG = YAML.load_file(File.join(File.dirname(__FILE__), '../../../..', 'config', 'swx.yml'))
    def process(params)
			# puts SWX_CONFIG.inspect
      # check for existence of service class and service method in params
                                                       # TODO: get rid of Rails specific methods
      klass = File.join(RAILS_ROOT, SWX_CONFIG['services_path'], params[:serviceClass].tableize.singularize)
      require klass
      service_class = params[:serviceClass].constantize.new
      
      # convert params from JSON to Ruby object
      # call service class#method with arguments
			# ================================================================
			# = TODO: cleanup code that determines whether to send arguments =
			# ================================================================
      service_class_response = json_to_ruby(params[:arguments]) ? service_class.send(params[:method], json_to_ruby(params[:arguments])) : service_class.send(params[:method])
        
      # assemble swx file and return it
      SwxAssembler.write_swf(service_class_response, params[:debug], SWX_CONFIG['compression_level'], params[:url], SWX_CONFIG['allow_domain'])
    end
    
    def json_to_ruby(arguments)
      JSON.parse arguments unless arguments.nil?
    end
  end
end