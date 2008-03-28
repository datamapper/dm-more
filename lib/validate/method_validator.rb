module DataMapper
  module Validate
    
    class MethodValidator < GenericValidator

      def initialize(method_name, options={})
        super
        @method_name, @options = method_name, options
        @options[:integer_only] = false unless @options.has_key?(:integer_only)
      end
      
      def call(target)    
        result,message = target.send(@method_name)        
        add_error(target,message,@method_name) if !result
        result
      end      
    end
    
    module ValidatesWithMethod
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods

        # Validate using a method. The method signiture needs to be
        # method_name() result::<Boolean>, Error Message::<String>
        #
        def validates_with_method(*fields)
          opts = opts_from_validator_args(fields)
          add_validator_to_context(opts, fields, DataMapper::Validate::MethodValidator)
        end        
      end
      
    end
    
  end  
end
