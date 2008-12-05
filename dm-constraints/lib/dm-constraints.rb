# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core', '~>0.9.7'
require 'dm-core'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'data_objects_adapter'
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'postgres_adapter'
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'mysql_adapter'

module DataMapper
  class AutoMigrator
    include Extlib::Hook
    include DataMapper::Constraints::DataObjectsAdapter::Migration
  end

  module Adapters
    if defined?(MysqlAdapter)
      MysqlAdapter.send :include, DataMapper::Constraints::MysqlAdapter::SQL
    end

    if defined?(PostgresAdapter)
      PostgresAdapter.send :include, DataMapper::Constraints::PostgresAdapter::SQL
    end
  end
end
