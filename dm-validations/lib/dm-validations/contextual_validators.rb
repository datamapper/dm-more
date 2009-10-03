require 'forwardable'

module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class ContextualValidators
      extend Forwardable

      #
      # Delegators
      #

      def_delegators :@contexts, :empty?, :each
      include Enumerable

      attr_reader :contexts

      def initialize
        @contexts = {}
      end

      #
      # API
      #

      # Return an array of validators for a named context
      #
      # @param  [String]
      #   Context name for which return validators
      # @return [Array<DataMapper::Validate::GenericValidator>]
      #   An array of validators
      def context(name)
        contexts[name] ||= []
      end

      # Clear all named context validators off of the resource
      #
      def clear!
        contexts.clear
      end

      # Execute all validators in the named context against the target
      #
      # @param [Symbol]
      #   named_context the context we are validating against
      # @param [Object]
      #   target        the resource that we are validating
      # @return [Boolean]
      #   true if all are valid, otherwise false
      def execute(named_context, target)
        target.errors.clear!

        context(named_context).map do |validator|
          validator.execute?(target) ? validator.call(target) : true
        end.all?
      end

    end # module ContextualValidators
  end # module Validate
end # module DataMapper
