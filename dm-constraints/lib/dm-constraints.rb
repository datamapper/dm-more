require 'pathname'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-constraints'

require dir / 'delete_constraint'
require dir / 'migrations'
require dir / 'version'

module DataMapper
  module Associations
    class OneToMany::Relationship
      include Extlib::Hook
      include Constraints::DeleteConstraint

      OPTIONS << :constraint

      attr_reader :constraint

      # initialize is a private method in Relationship
      # and private methods can not be "advised" (hooked into)
      # in extlib.
      with_changed_method_visibility(:initialize, :private, :public) do
        before :initialize, :add_constraint_option
      end
    end

    class ManyToMany::Relationship
      OPTIONS << :constraint
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

    module Model
      include Constraints::Migrations::Model
    end
  end
end
