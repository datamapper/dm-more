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
        def check_delete_constraint_type(cardinality, name, *args)
          options = extract_options(args)

          return unless options.key?(:constraint)

          constraint = options[:constraint]

          unless CONSTRAINT_OPTIONS.include?(constraint)
            raise ArgumentError, ":constraint option must be one of #{CONSTRAINT_OPTIONS.to_a.join(', ')}"
          end

          # XXX: is any constraint valid with a :through relationship?
          if constraint == :set_nil && options.key?(:through)
            raise ArgumentError, 'Constraint type :set_nil is not valid for relationships using :through'
          end
        end

        private

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
      # Adds the delete constraint options to a relationship
      #
      # @param params [*ARGS] Arguments passed to Relationship#initialize
      #
      # @return [nil]
      #
      # @api semi-public
      def add_constraint_option(name, child_model, parent_model, options = {})
        @constraint = options.fetch(:constraint, :protect) || :skip
      end

      private

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
        relationships.each_value do |relationship|
          next unless relationship.respond_to?(:constraint)
          next unless association = relationship.get(self)

          delete_allowed = case constraint = relationship.constraint
            when :protect
              Array(association).empty?
            when :destroy, :destroy!
              association.__send__(constraint)
            when :set_nil
              Array(association).all? do |resource|
                resource.update(relationship.inverse => nil)
              end
            when :skip
              true  # do nothing
          end

          throw(:halt, false) unless delete_allowed
        end
      end
    end # DeleteConstraint
  end # Constraints
end # DataMapper
