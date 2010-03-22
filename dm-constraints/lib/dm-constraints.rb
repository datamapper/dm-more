require 'dm-core'

require 'dm-constraints/delete_constraint'
require 'dm-constraints/migrations'

module DataMapper
  module Associations
    class OneToMany::Relationship
      include DataMapper::Hook
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

      private

      # TODO: document
      # @api semipublic
      chainable do
        def one_to_many_options
          super.merge(:constraint => @constraint)
        end
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

    Model.append_inclusions self
  end

  module Migrations
    constants.each do |const_name|
      if Constraints::Migrations.const_defined?(const_name)
        mod = const_get(const_name)
        mod.send(:include, Constraints::Migrations.const_get(const_name))
      end
    end
  end
end
