module DataMapper 
  module Validate 
    module AutoValidate
    
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods     
        
        # Auto generate validations for a given property. This will only occur
        # if the option :auto_validations is true or undefined.
        # 
        # ==== Triggers that generate validator creation
        #
        # :nullable => false 
        #       Setting the option :nullable to false causes a validates_presence_of 
        #       validator to be automatically created on the property
        #
        # :size => 20 or :length => 20
        #       Setting the option :size or :length causes a validates_length_of  
        #       validator to be automatically created on the property. If the value
        #       is a Fixnum the validation will set :maximum => value if the value
        #       is a Range the validation will set :within => value
        #
        # :format => :predefined / lambda / Proc
        #       Setting the :format option causes a validates_format_of validatior
        #       to be automatically created on the property
        #   
        #
        def auto_generate_validations_for_property(property)
          property.options[:auto_validation] = true unless property.options.has_key?(:auto_validation)
          return unless property.options[:auto_validation]
          
          opts = {}
          opts[:context] = property.options[:validation_context] if property.options.has_key?(:validation_context)
          
          # presence
          if property.options.has_key?(:nullable) && !property.options[:nullable]
            validates_presence_of property.name, opts
          end
          
          # length
          if property.options.has_key?(:length) || property.options.has_key?(:size)
            len = property.options.has_key?(:length) ? property.options[:length] : property.options[:size]
            opts[:within] = len if len.is_a?(Range)
            opts[:maximum] = len unless len.is_a?(Range)
            validates_length_of property.name, opts
          end
          
          #format
          if property.options.has_key?(:format)
            opts[:with] = property.options[:format]
            validates_format_of property.name, opts
          end
      

        end
      end
    end
  end
end
