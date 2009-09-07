require 'pathname'
require 'extlib/pathname'

require 'rails_datamapper/session_store'

module Rails
  module DataMapper
    class << self
      extend ActiveSupport::Memoizable

      def create_connection
        # TODO: handle Rails and Merb style database.yml files
        conf = config.dup
        repositories = conf.delete(:repositories)
        ::DataMapper.setup(:default, conf) unless conf.empty?
      end

    private

      def config_file
        Rails.root / 'config' / 'database.yml'
      end

      def full_config
        YAML::load(ERB.new(config_file.read).result)
      end

      memoize :full_config

      def config
        if hash = full_config[Rails.env] || full_config[Rails.env.to_sym]
          normalize_config(hash)
        else
          raise ArgumentError, "missing environment '#{Rails.env}' in config file #{config_file}"
        end
      end

      memoize :config

      def normalize_config(hash)
        config = {}

        hash.symbolize_keys.each do |key, value|
          config[key] = if value.kind_of?(Hash)
            normalize_config(value)
          elsif key == :port
            value.to_i
          elsif key == :adapter && value == 'postgresql'
            'postgres'
          else
            value
          end
        end

        config
      end
    end
  end
end

Rails::DataMapper.create_connection
