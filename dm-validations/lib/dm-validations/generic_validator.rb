module DataMapper
  module Validate

    # All validators extend this base class. Validators must: 
    #
    # * Implement the initialize method to capture its parameters, 
    #   also calling super to have this parent class capture the 
    #   optional, general :if and :unless parameters.
    # * Implement the call method, returning true or false. 
    #   The call method provides the validation logic.
    #
    class GenericValidator

      attr_accessor :if_clause
      attr_accessor :unless_clause

      # Construct a validator. Capture the :if and :unless clauses 
      # when present.
      # 
      # ==== Parameters
      # field <String, Symbol>:: The property specified for validation
      #
      # ==== Options (opts)
      # :if<Symbol, Proc>:: The name of a method or a Proc to call to 
      #                     determine if the validation should occur. 
      # :unless<Symbol, Proc>:: The name of a method or a Proc to call to 
      #                         determine if the validation should not occur
      # All additional key/value pairs are passed through to the validator 
      # that is sub-classing this GenericValidator
      #
      def initialize(field, opts = {})
        @if_clause = opts.has_key?(:if) ? opts[:if] : nil
        @unless_clause = opts.has_key?(:unless) ? opts[:unless] : nil
      end

      # Add an error message to a target resource. If the error corresponds to a
      # specific field of the resource, add it to that field, otherwise add it
      # as a :general message.
      #
      # ==== Parameters
      # target<Object>:: The resource (model) that has the error
      # message<String>:: The message to add
      # field_name<Symbol>:: The property that has the error, defaults to :general
      #
      #--
      # TODO - should the field_name for a general message be :default???
      #
      def add_error(target, message, field_name = :general)
        target.errors.add(field_name,message)
      end

      # Call the validator. "call" is used so the operation is BoundMethod and
      # Block compatible. This must be implemented in all concrete classes.
      #
      # ==== Parameters
      # target<Object>:: The resource that the validator must be called
      #                  against
      #
      # ==== Returns
      # Boolean:: True if valid, false otherwise
      def call(target)
        raise "DataMapper::Validate::GenericValidator::call must be overriden in #{self.class.to_s}"
      end

      def field_name
        @field_name
      end

      # Determines if this validator should be run against the 
      # target by evaluating the :if and :unless clauses 
      # optionally passed while specifying any validator.
      #
      # ==== Parameters
      # target<Object>:: The resource that we check against
      #
      # ==== Returns
      # Boolean:: True if should be run, false otherwise
      def execute?(target)
        return true if self.if_clause.nil? && self.unless_clause.nil?

        if self.unless_clause
          if self.unless_clause.is_a?(Symbol)
            return false if target.send(self.unless_clause)
          elsif self.unless_clause.respond_to?(:call)
            return false if self.unless_clause.call(target)
          end
        end

        if self.if_clause
          if self.if_clause.is_a?(Symbol)
            return target.send(self.if_clause)
          elsif self.if_clause.respond_to?(:call)
            return self.if_clause.call(target)
          end
        end
        return true
      end

    end # class GenericValidator
  end # module Validate
end # module DataMapper
