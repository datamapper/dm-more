module DataMapper
  module Validate
    
    # A base class that all validators must be derived from. Child classes
    # must implement the abstract method call where the actual validation 
    # occures
    #
    class GenericValidator
      
      attr_accessor :if_clause
      
      # Construct a validator. Capture the :if clause when one is present
      #
      def initialize(field, opts = {})
        @if_clause = opts.has_key?(:if) ? opts[:if] : nil        
      end
      
      # Add an error message to a target resource. If the error corrosponds
      # to a specific field of the resource, add it to that field, otherwise
      # add it as a :general message
      #
      # ==== Parameters
      #   target<Object>::        the resource that has the error
      #   message<String>::       a string message to add 
      #   field_name<Symbol>      the name of the field that caused the error
      def add_error(target, message, field_name = :general)
        target.errors.add(field_name,message)
      end
    
      # Call the validator. "call" is used so the operation is BoundMethod and
      # Block compatible. This must be implemented in all concreate classes
      #
      # ==== Parameters
      #   target<Object>:: the resource that the validator must be called against"
      #
      # ==== Returns
      # <Boolean>:: TRUE if valid otherwise FALSE
      #
      def call(target)
        raise "DataMapper::Validate::GenericValidator::call must be overriden in #{self.class.to_s}" 
      end
      
      
      # Determine if this validator should be run against the target
      #
      # ==== Parameters
      #   target<Object>:: the resource that we check against
      #
      # ==== Returns
      # <Boolean>:: TRUE if should be run otherwise FALSE
      #
      def execute?(target)
        return true unless self.if_clause
        if self.if_clause.is_a?(Symbol)
          return target.send(self.if_clause)
        elsif self.if_clause.respond_to?(:call)
          return self.if_clause.call(target)
        else
          return true
        end
      end      
      
    end        
  end
end
