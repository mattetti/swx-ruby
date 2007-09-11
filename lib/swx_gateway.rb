require 'json'
require 'swx_assembler'
require 'yaml'

class SwxGateway
  class << self
		# Define RAILS_ROOT here to make spec suite run in isolation from Rails
		RAILS_ROOT = File.join(File.dirname(__FILE__), '../../../..')
		# ====================================================================================
		# = TODO: Make sure that YAML.load_file is only called once instead of every request =
		# ====================================================================================
		SWX_CONFIG = YAML.load_file(File.join(RAILS_ROOT, 'config', 'swx.yml'))
		
		def init_service_class(service_class)
			klass = File.join(RAILS_ROOT, SWX_CONFIG['services_path'], service_class.underscore)
      require klass
      service_class.constantize
		end
		
    def process(params)
      # check for existence of service class and service method in params
      service_class = init_service_class(params[:serviceClass])

      # call service class#method with arguments
			# ================================================================
			# = TODO: cleanup code that determines whether to send arguments =
			# ================================================================
      service_class_response = json_to_ruby(params[:arguments]) ? service_class.new.send(params[:method], json_to_ruby(params[:arguments])) : service_class.new.send(params[:method])
        
      # assemble swx file and return it
      SwxAssembler.write_swf(service_class_response, params[:debug], SWX_CONFIG['compression_level'], params[:url], SWX_CONFIG['allow_domain'])
    end
    
    def json_to_ruby(arguments)
      JSON.parse arguments unless arguments.nil?
    end
  end
end