module DataMapper 
  module Validate 
    class ContextualValidators
      
      class UnknownContextError < StandardError; end
      
      
      def dump
        contexts.each_pair do |key,context|
          puts "Key=#{key} Context: #{context}"
        end
      end
      
      # Get a hash of named context validators for the resource
      #
      # ==== Returns
      # <Hash>:: a hash of validators <GenericValidator>
      #
      def contexts
        @contexts ||= @contexts = {}
      end
      
      # Return an array of validators for a named context
      #      
      def context(name)
        contexts[name] = [] unless contexts.has_key?(name)
        contexts[name]
      end
    
      
      # Clear all named context validators off of the resource
      #
      def clear!
        contexts.clear
      end

      # Execute all validators in the named context against the target
      #
      # ==== Parameters
      #
      #   named_context<Symbol>::  - the context we are validating against
      #   target<Object>::         - the resource that we are validating
      #
      # ==== Return Value
      def execute(named_context, target)
        target.errors.clear!
        result = true
        context(named_context).each do |validator|
          if validator.execute?(target)
            result = false if !validator.call(target)
          end
        end
        return result
      end

      
#  target.errors.clear!
      #  
      #  validations = context(context_name)
      #  validations += context(:general) unless context_name == :general
        
      #  validations.inject(true) do |result, validator|
      #    if validator.execute_validation?(target)
      #      result & validator.call(target)
      #    else
      #      result
      #    end
      #   end      
      
      
      
      
      
      
      # This will be raised when you try to access
      # a context that's not a member of the DEFAULT_CONTEXTS array.
      #class UnknownContextError < StandardError
      #end
      
      # Add your custom contexts here.
      #DEFAULT_CONTEXTS = [
      #    :general, :create, :save, :update
      #  ]
        
      #def initialize
        #@contexts = Hash.new { |h,k| h[k.to_sym] = [] }
      #end
      
      # Retrieves a context by symbol.
      # Raises an exception if the symbol isn't a member of DEFAULT_CONTEXTS.
      # This isn't to keep you from adding your own contexts, it's just to
      # prevent errors due to typos. When adding your own contexts just
      # remember to add it to DEFAULT_CONTEXTS first.
      #def context(name)
      #  raise UnknownContextError.new(name) unless DEFAULT_CONTEXTS.include?(name)
      #  @contexts[name]
      #end
      
      # Clear out all the currently defined validators.
      # This makes testing easier.
      #def clear!
      #  @contexts.clear
      #end
      
      # Execute all validations against an instance for a specified context,
      # including the "always-on" :general context.
      #def execute(context_name, target)
      #  target.errors.clear!
      #  
      #  validations = context(context_name)
      #  validations += context(:general) unless context_name == :general
        
      #  validations.inject(true) do |result, validator|
      #    if validator.execute_validation?(target)
      #      result & validator.call(target)
      #    else
      #      result
      #    end
      #   end
      #end
        
    end
  end
end
