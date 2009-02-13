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

      def add_delete_constraint_option(*params)
        opts = params.last
        
        if opts.is_a?(Hash)
          opts[:constraint] ||= nil  #Make sure options contains :constraint key, whether nil or not
          #if it is a chain, set the constraint on the 1:M near relationship(anonymous)
          if self.is_a?(DataMapper::Associations::RelationshipChain)
            raise Exception.new(":constraint => :set_nil is not valid for M:M relationships") if opts[:constraint] == :set_nil
            opts = params.last
            near_rel = opts[:parent_model].relationships[opts[:near_relationship_name]]
            near_rel.options[:constraint] = opts[:constraint]
            near_rel.instance_variable_set "@delete_constraint", opts[:constraint]
          end
          
          @delete_constraint = params.last[:constraint]  
        end
      end

      # TODO.  Doesnt support 1:1 foreign key constraints
      def check_delete_constraints
        model.relationships.each do |rel_name, rel|
          #Don't delete across M:M relationships, instead use their anonymous 1:M Relationships
          next if rel.is_a?(DataMapper::Associations::RelationshipChain)
          
          children = self.send(rel_name)
          case rel.delete_constraint
          when nil, :protect
            # only prevent deletion if the resource is a parent in a relationship and has children
            if children && children.respond_to?(:empty?) && !children.empty?
              DataMapper.logger.info("Could not delete a #{self.class} a child record exists #{children.first.class}")
              throw(:halt,false) 
            end
          when :destroy
            if children && children.respond_to?(:each)
              children.each{|child| child.destroy}
            end
          when :destroy!
            if children
              # not sure why but this lazy_load is necessary
              # otherwise children will not be deleted with destroy!
              children.lazy_load
              children.destroy!
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
