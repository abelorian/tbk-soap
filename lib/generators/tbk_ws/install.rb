module TransbankWebpay
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('.', __FILE__)

      def generate_config_file
        copy_file 'tbk_ws_config.rb', 'config/initializers/tbk_ws_config.rb'
      end
    end
  end
end
