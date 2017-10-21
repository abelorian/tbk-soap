module Transbank
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def generate_config_file
        copy_file 'transbank_config.rb', 'config/initializers/transbank_config.rb'
      end
    end
  end
end
