require 'swx_gateway'
require 'yaml'

# Tell SwxGateway where app root and config file are located
SwxGateway.app_root = RAILS_ROOT
SwxGateway.swx_config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'swx.yml'))

# Initialize Rails integration
require File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'rails_integration', 'render_decorator'))

# Register the SWX mime tytpe
Mime::Type.register "application/swf", :swx