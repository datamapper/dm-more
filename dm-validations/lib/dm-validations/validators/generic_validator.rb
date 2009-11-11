# -*- coding: utf-8 -*-
module DataMapper
  module Validate

    # All validators extend this base class. Validators must:
    #
    # * Implement the initialize method to capture its parameters, also calling
    #   super to have this parent class capture the optional, general :if and
    #   :unless parameters.
    # * Implement the call method, returning true or false. The call method
    #   provides the validation logic.
    #
    # @author Guy van den Berg
    # @since  0.9
    class GenericValidator

      attr_accessor :if_clause, :unless_clause
      attr_reader   :field_name, :options, :humanized_field_name

      # Construct a validator. Capture the :if and :unless clauses when present.
      #
      # @param field<String, Symbol> The property specified for validation
      #
      # @option :if<Symbol, Proc>   The name of a method or a Proc to call to
      #                     determine if the validation should occur.
      # @option :unless<Symbol, Proc> The name of a method or a Proc to call to
      #                         determine if the validation should not occur
      # All additional key/value pairs are passed through to the validator
      # that is sub-classing this GenericValidator
      #
      def initialize(field_name, options = {})
        @field_name           = field_name
        @options              = options.except(:if, :unless)
        @if_clause            = options[:if]
        @unless_clause        = options[:unless]
        @humanized_field_name = Extlib::Inflection.humanize(@field_name)
      end

      # Add an error message to a target resource. If the error corresponds to a
      # specific field of the resource, add it to that field, otherwise add it
      # as a :general message.
      #
      # @param <Object> target the resource that has the error
      # @param <String> message the message to add
      # @param <Symbol> field_name the name of the field that caused the error
      #
      # TODO - should the field_name for a general message be :default???
      #
      def add_error(target, message, field_name = :general)
        target.errors.add(field_name, message)
      end

      # Call the validator. "call" is used so the operation is BoundMethod and
      # Block compatible. This must be implemented in all concrete classes.
      #
      # @param <Object> target  the resource that the validator must be called
      #                         against
      # @return <Boolean> true if valid, otherwise false
      def call(target)
        raise NotImplementedError, "#{self.class}#call must be implemented"
      end

      # Determines if this validator should be run against the
      # target by evaluating the :if and :unless clauses
      # optionally passed while specifying any validator.
      #
      # @param <Object> target the resource that we check against
      # @return <Boolean> true if should be run, otherwise false
      def execute?(target)
        if unless_clause = self.unless_clause
          return !target.__send__(unless_clause) if unless_clause.kind_of?(Symbol)
          return !unless_clause.call(target)     if unless_clause.respond_to?(:call)
        end

        if if_clause = self.if_clause
          return target.__send__(if_clause) if if_clause.kind_of?(Symbol)
          return if_clause.call(target)     if if_clause.respond_to?(:call)
        end

        true
      end

      # Set the default value for allow_nil and allow_blank
      #
      # @param [Boolean] default value
      # @return <undefined>
      def set_optional_by_default(default = true)
        [ :allow_nil, :allow_blank ].each do |key|
          @options[key] = true unless options.key?(key)
        end
      end

      # Test the value to see if it is blank or nil, and if it is allowed
      #
      # @param <Object> value to test
      # @return <Boolean> true if blank/nil is allowed, and the value is blank/nil
      def optional?(value)
        return allow_nil?(value)   if value.nil?
        return allow_blank?(value) if value.blank?
        false
      end

      # Test if the value is nil and is allowed
      #
      # @param <Object> value to test
      # @return <Boolean> true if nil is allowed and value is nil
      def allow_nil?(value)
        @options[:allow_nil] if value.nil?
      end

      # Test if the value is blank and is allowed
      #
      # @param <Object> value to test
      # @return <Boolean> true if blank is allowed and value is blank
      def allow_blank?(value)
        @options[:allow_blank] if value.blank?
      end

      # Returns true if validators are equal
      #
      # Note that this intentionally do
      # validate options equality
      #
      # even though it is hard to imagine a situation
      # when multiple validations will be used
      # on the same field with the same conditions
      # but different options,
      # it happens to be the case every once in a while
      # with inferred validations for strings/text and
      # explicitly given validations with different option
      # (usually as Range vs. max limit for inferred validation)
      #
      # @semipublic
      def ==(other)
        self.class == other.class &&
        self.field_name == other.field_name &&
        self.if_clause == other.if_clause &&
        self.unless_clause == other.unless_clause &&
        self.instance_variable_get(:@options) == other.instance_variable_get(:@options)
      end

      def inspect
        "<##{self.class.name} @field_name='#{@field_name}' @if_clause=#{@if_clause.inspect} @unless_clause=#{@unless_clause.inspect} @options=#{@options.inspect}>"
      end

      alias to_s inspect
    end # class GenericValidator
  end # module Validate
end # module DataMapper
