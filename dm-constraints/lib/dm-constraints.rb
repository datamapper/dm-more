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
      attr_reader :delete_constraint
      OPTIONS << :constraint

      def initialize(name, repository_name, child_model, parent_model, options = {})
        assert_kind_of 'name',            name,            Symbol
        assert_kind_of 'repository_name', repository_name, Symbol
        assert_kind_of 'child_model',     child_model,     String, Class
        assert_kind_of 'parent_model',    parent_model,    String, Class

        if child_properties = options[:child_key]
          assert_kind_of 'options[:child_key]', child_properties, Array
        end

        if parent_properties = options[:parent_key]
          assert_kind_of 'options[:parent_key]', parent_properties, Array
        end

        @name              = name
        @repository_name   = repository_name
        @child_model       = child_model
        @child_properties  = child_properties   # may be nil
        @query             = options.reject { |k,v| OPTIONS.include?(k) }
        @parent_model      = parent_model
        @parent_properties = parent_properties  # may be nil
        @options           = options
        @delete_constraint = options[:constraint]

        # attempt to load the child_key if the parent and child model constants are defined
        if model_defined?(@child_model) && model_defined?(@parent_model)
          child_key
        end
      end

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
