module DataMapper
  module Validate
    
    class NumericValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
        @options[:integer_only] = false unless @options.has_key?(:integer_only)
      end
      
      def call(target)      
        value =  target.instance_variable_get("@#{@field_name}").to_s
        regex = @options[:integer_only] ? /\A[+-]?\d+\Z/ : /^\d*\.{0,1}\d+$/
        return true if not (value =~ regex).nil?
        
        error_message = @options[:message] || "%s must be a number".t(DataMapper::Inflection.humanize(@field_name))
        add_error(target, error_message , @field_name)
        
        return false
      end      
    end
    
    module ValidatesNumericalnesOf
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods

        # Validate the absence of a field
        #
        def validates_numericalnes_of(*fields)
          opts = opts_from_validator_args(fields)
          add_validator_to_context(opts, fields, DataMapper::Validate::NumericValidator)
        end        
      end
      
    end
    
  end  
end
