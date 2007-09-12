require 'swx_gateway'
require 'yaml'

# Tell SwxGateway where app root and config file are located
SwxGateway.app_root = RAILS_ROOT
SwxGateway.swx_config = YAML.load_file(File.join(RAILS_ROOT, 'config', 'swx.yml'))