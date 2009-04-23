module DataMapper
  module Constraints
    module DeleteConstraint
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        CONSTRAINT_OPTIONS = [ :protect, :destroy, :destroy!, :set_nil, :skip ].to_set.freeze

        ##
        # Checks that the constraint type is appropriate to the relationship
        #
        # @param cardinality [Fixnum] cardinality of relationship
        #
        # @param name [Symbol] name of relationship to evaluate constraint of
        #
        # @param options [Hash] options hash
        #
        # @raises ArgumentError
        #
        # @return [nil]
        #
        # @api semi-public
        def check_delete_constraint_type(cardinality, name, options = {})
          return unless options.key?(:constraint)

          constraint_type = options[:constraint]

          unless CONSTRAINT_OPTIONS.include?(constraint_type)
            raise ArgumentError, ":constraint option must be one of #{CONSTRAINT_OPTIONS.to_a.join(', ')}"
          end

          if constraint_type == :set_nil && options.key?(:through)
            raise ArgumentError, 'Constraint type :set_nil is not valid for relationships using :through'
          end

          min, max = extract_min_max(cardinality)

          if max == 1 && constraint_type == :destroy!
            raise ArgumentError, 'Constraint type :destroy! is not valid for one-to-one relationships'
          end
        end

        ##
        # Temporarily changes the visibility of a method so a block can be evaluated against it
        #
        # @param method [Symobl] method to change visibility of
        #
        # @param from_visibility [Symbol] original visibility
        #
        # @param to_visibility [Symbol] temporary visibility
        #
        # @param block [Proc] proc to run
        #
        # @notes  TODO: this should be moved to a 'util-like' module
        #
        # @return [nil]
        #
        # @api semi-public
        def with_changed_method_visibility(method, from_visibility, to_visibility, &block)
          send(to_visibility, method)
          yield
        ensure
          send(from_visibility, method)
        end
      end

      ##
      # Addes the delete constraint options to a relationship
      #
      # @param params [*ARGS] Arguments passed to Relationship#initialize or RelationshipChain#initialize
      #
      # @notes This takes *params because it runs before the initializer for Relationships and Many to Many Relationships
      #   which have different method signatures
      #
      # @return [nil]
      #
      # @api semi-public
      def add_constraint_option(name, child_model, parent_model, options = {})
        @constraint = options.delete(:constraint) || :protect
      end

      ##
      # Checks delete constraints prior to destroying a dm resource or collection
      #
      # @throws :halt
      #
      # @notes
      #   - It only considers a relationship's constraints if this is the parent model (ie a child shouldn't delete a parent)
      #   - Many to Many Relationships are skipped, as they are evaluated by their underlying 1:M relationships
      #
      # @returns [nil]
      #
      # @api semi-public
      def check_delete_constraints
        relationships.each do |relationship_name, relationship|
          next if relationship.kind_of?(Associations::ManyToOne::Relationship)
          next unless constraint_type = relationship.constraint
          next unless association = relationship.get(self)

          case constraint_type
            when :protect
              throw(:halt, false) if Array(association).any?
            when :destroy, :destroy!
              association.send(constraint_type)
            when :set_nil
              # TODO: expose a method called orphan in the relationships
              # that orphans a resource from an association
              Array(association).each { |r| relationship.target_key.set(r, []); r.save }
            when :skip
              # do nothing
          end
        end
      end # check_delete_constraints
    end # DeleteConstraint
  end # Constraints
end # DataMapper
