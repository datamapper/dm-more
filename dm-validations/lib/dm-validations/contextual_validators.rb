require "forwardable"

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

      def dump
        contexts.each_pair do |key, context|
          puts "Key=#{key} Context: #{context}"
        end
      end
      alias_method :inspect, :dump

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
        raise(ArgumentError, "validation context #{named_context} doesn't seem to be defined. Known contexts are #{contexts.keys.inspect}") if !named_context || (contexts.length > 0 && !contexts[named_context])
        target.errors.clear!
        result = true
        # note that all? and any? stop iteration on first negative or positive result,
        # so we really have to use each here to make sure all validators are
        # executed
        context(named_context).select { |validator| validator.execute?(target) }.each do |validator|
          result = false unless validator.call(target)
        end


        result
      end

    end # module ContextualValidators
  end # module Validate
end # module DataMapper
