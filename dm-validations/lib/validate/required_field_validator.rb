module DataMapper
  module Validate
    
    class RequiredFieldValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
      end
      
      def call(target)
        field_value = !target.instance_variable_get("@#{@field_name}").blank?
        return true if field_value
        
        error_message = @options[:message] || "%s must not be blank".t(Inflector.humanize(@field_name))
        add_error(target, error_message , @field_name)
        
        return false
      end
      
    end
    
    module ValidatesPresenceOf
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods

        # Validate the presence of a field
        #
        def validates_presence_of(*fields)
          opts = opts_from_validator_args(fields)
          add_validator_to_context(opts, fields, DataMapper::Validate::RequiredFieldValidator)
        end        
      end
      
    end
    
  end  
end
