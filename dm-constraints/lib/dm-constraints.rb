# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core', '0.10.0'
require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path

require dir / 'dm-constraints' / 'delete_constraint'
require dir / 'dm-constraints' / 'migrations'

module DataMapper
  module Associations
    class Relationship
      include Extlib::Hook
      include Constraints::DeleteConstraint

      attr_reader :constraint
      OPTIONS << :constraint

      # initialize is a private method in Relationship
      # and private methods can not be "advised" (hooked into)
      # in extlib.
      with_changed_method_visibility(:initialize, :private, :public) do
        before :initialize, :add_constraint_option
      end
    end
  end

  module Constraints
    include DeleteConstraint

    module ClassMethods
      include DeleteConstraint::ClassMethods
    end

    ##
    # Add before hooks to #has to check for proper constraint definitions
    # Add before hooks to #destroy to properly constrain children
    #
    def self.included(model)
      model.extend(ClassMethods)
      model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        before_class_method :has, :check_delete_constraint_type

        if instance_methods.any? { |m| m.to_sym == :destroy }
          before :destroy, :check_delete_constraints
        end
      RUBY
    end
  end

  module Migrations
    module SingletonMethods
      include Constraints::Migrations::SingletonMethods
    end

    module DataObjectsAdapter
      include Constraints::Migrations::DataObjectsAdapter
    end

    module MysqlAdapter
      include Constraints::Migrations::MysqlAdapter
    end
  end
end
