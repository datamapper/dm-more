module DataMapper
  module Constraints
    module DeleteConstraint

      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        DELETE_CONSTRAINT_OPTIONS = [:protect, :destroy, :destroy!, :set_nil, :skip]
        def check_delete_constraint_type(cardinality, name, options = {})
          constraint_type = options[:constraint]
          return if constraint_type.nil?
          delete_constraint_options = DELETE_CONSTRAINT_OPTIONS.map { |o| ":#{o}" }
          if !DELETE_CONSTRAINT_OPTIONS.include?(constraint_type)
            raise ArgumentError, ":constraint option must be one of #{delete_constraint_options * ', '}"
          end
        end

        # TODO: that should be moved to a 'util-like' module
        def with_changed_method_visibility(method, from_visibility, to_visibility, &block)
          send(to_visibility, method)
          yield
          send(from_visibility, method)
        end

      end

      def add_delete_constraint_option(name, repository_name, child_model, parent_model, options = {})
        @delete_constraint = options[:constraint]
      end

      def check_delete_constraints
        model.relationships.each do |rel_name, rel|
          children = self.send(rel_name)
          case rel.delete_constraint
          when nil, :protect
            # only prevent deletion if the resource is a parent in a relationship and has children
            throw(:halt, false) if children && children.respond_to?(:empty?) && !children.empty?
          when :destroy
            if children && children.respond_to?(:each)
              children.each { |child| child.destroy }
            end
          when :set_nil
            if children && children.respond_to?(:each)
              children.each do |child|
                child.class.many_to_one_relationships.each do |mto_rel|
                  child.send("#{mto_rel.name}=", nil) if child.send(mto_rel.name).eql?(self)
                end
              end
            end
          end # case
        end # relationships
      end # check_delete_constraints


    end # DeleteConstraint
  end # Constraints
end # DataMapper
