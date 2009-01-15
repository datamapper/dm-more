# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core', '~>0.9.10'
require 'dm-core'

# Require plugin-files
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'data_objects_adapter'
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'postgres_adapter'
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'mysql_adapter'
require Pathname(__FILE__).dirname.expand_path / 'dm-constraints' / 'delete_constraint'

module DataMapper
  module Associations
    class Relationship
      include Extlib::Hook
      include DataMapper::Constraints::DeleteConstraint
      
      attr_reader :delete_constraint
      OPTIONS << :constraint
      
      # initialize is a private method in Relationship
      # and private methods can not be "advised" (hooked into)
      # in extlib.
      public(:initialize)
      before :initialize, :add_delete_constraint_option
      private(:initialize)
    end
  end
end

module DataMapper
  module Constraints
    
    include DeleteConstraint
    
    module ClassMethods
      include DeleteConstraint::ClassMethods
    end
        
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval do
        before_class_method :has, :check_delete_constraint_type
        if method_defined?(:destroy)
          before :destroy, :check_delete_constraints
        end
      end
    end
    
  end

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
