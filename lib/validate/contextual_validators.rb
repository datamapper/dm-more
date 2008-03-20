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
      # <Boolean>:: - true if all is valid otherwise false
      #
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

    end
  end
end
