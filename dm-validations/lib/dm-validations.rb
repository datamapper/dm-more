require 'rubygems'
gem 'dm-core', '=0.9.0'
require 'data_mapper'

require File.join(File.dirname(__FILE__),'dm-validations','validation_errors')
require File.join(File.dirname(__FILE__),'dm-validations','contextual_validators')
require File.join(File.dirname(__FILE__),'dm-validations','auto_validate')


require File.join(File.dirname(__FILE__),'dm-validations','generic_validator')
require File.join(File.dirname(__FILE__),'dm-validations','required_field_validator')
require File.join(File.dirname(__FILE__),'dm-validations','absent_field_validator')
require File.join(File.dirname(__FILE__),'dm-validations','confirmation_validator')
require File.join(File.dirname(__FILE__),'dm-validations','format_validator')
require File.join(File.dirname(__FILE__),'dm-validations','length_validator')
require File.join(File.dirname(__FILE__),'dm-validations','within_validator')
require File.join(File.dirname(__FILE__),'dm-validations','numeric_validator')
require File.join(File.dirname(__FILE__),'dm-validations','method_validator')
require File.join(File.dirname(__FILE__),'dm-validations','uniqueness_validator')
require File.join(File.dirname(__FILE__),'dm-validations','acceptance_validator')

require File.join(File.dirname(__FILE__),'dm-validations','support','object')



module DataMapper
  module Validate
      
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
         include DataMapper::Validate::ValidatesPresenceOf
         include DataMapper::Validate::ValidatesAbsenceOf
         include DataMapper::Validate::ValidatesConfirmationOf
         include DataMapper::Validate::ValidatesAcceptanceOf
         include DataMapper::Validate::ValidatesFormatOf
         include DataMapper::Validate::ValidatesLengthOf         
         include DataMapper::Validate::ValidatesWithin
         include DataMapper::Validate::ValidatesNumericalnesOf
         include DataMapper::Validate::ValidatesWithMethod
         include DataMapper::Validate::ValidatesUniquenessOf
         include DataMapper::Validate::AutoValidate
         
        end
      end
      
      # Return the ValidationErrors
      #    
      def errors
        @errors ||= ValidationErrors.new
      end
      
      # Mark this resource as validatable. When we validate associations of a 
      # resource we can check if they respond to validatable? before trying to
      # recursivly validate them
      #
      def validatable?()
        true
      end
      
      # Alias for valid?(:default)
      #
      def valid_for_default?
        valid?(:default)
      end
      
      # Check if a resource is valid in a given context
      #
      def valid?(context = :default)
        self.class.validators.execute(context,self)        
      end
      
      # Begin a recursive walk of the model checking validity
      #
      def all_valid?(context = :default)
        recursive_valid?(self,context,true)
      end
      
      # Do recursive validity checking
      #
      def recursive_valid?(target, context, state)    
        valid = state
        target.instance_variables.each do |ivar|
          ivar_value = target.instance_variable_get(ivar) 
          if ivar_value.validatable?
            valid = valid && recursive_valid?(ivar_value,context,valid)
          elsif ivar_value.respond_to?(:each)
            ivar_value.each do |item|
              if item.validatable?
                valid = valid && recursive_valid?(item,context,valid)
              end
            end          
          end
        end
        return valid && target.valid?
      end
      
      
      def validation_property_value(name)
        return self.instance_variable_get("@#{name}") if self.instance_variables.include?(name)
        return self.send(name) if self.respond_to?(name)
        nil
      end
      
      def validation_association_keys(name)
        if self.class.relationships.has_key?(name)
          result = []
          relation = self.class.relationships[name]
          relation.child_key.each do |key|
            result << key.name
          end
          return result
        end           
        nil   
      end  
      
      module ClassMethods
        
        # Return the set of contextual validators or create a new one
        #
        def validators
          @validations ||= ContextualValidators.new
        end
        
        # Clean up the argument list and return a opts hash, including the 
        # merging of any default opts. Set the context to default if none is
        # provided. Also allow :context to be aliased to :on, :when & group
        #
        def opts_from_validator_args(args, defaults = nil)
          opts = args.last.kind_of?(Hash) ? args.pop : {}
          context = :default          
          context = opts[:context] if opts.has_key?(:context)
          context = opts.delete(:on) if opts.has_key?(:on)
          context = opts.delete(:when) if opts.has_key?(:when)
          context = opts.delete(:group) if opts.has_key?(:group)
          opts[:context] = context
          opts.mergs!(defaults) unless defaults.nil?
          opts        
        end   
        
        # Given a new context create an instance method of 
        # valid_for_<context>? which simply calls valid?(context)
        # if it does not already exist
        #
        def create_context_instance_methods(context)
          name = "valid_for_#{context.to_s}?"
          if !self.instance_methods.include?(name)
            class_eval <<-EOS
              def #{name}
                valid?('#{context.to_s}'.to_sym)
              end
            EOS
          end
          
          all = "all_valid_for_#{context.to_s}?"
          if !self.instance_methods.include?(all)
            class_eval <<-EOS
              def #{all}
                all_valid?('#{context.to_s}'.to_sym)
              end
            EOS
          end
        end
        
        # Create a new validator of the given klazz and push it onto the 
        # requested context for each of the fields in the fields list
        #
        def add_validator_to_context(opts, fields, klazz)
          fields.each do |field|
            if opts[:context].is_a?(Symbol)
              validators.context(opts[:context]) << klazz.new(field, opts)
              create_context_instance_methods(opts[:context])
            elsif opts[:context].is_a?(Array)
              opts[:context].each do |c| 
                validators.context(c) << klazz.new(field, opts)
                create_context_instance_methods(c)
              end
            end
          end        
        end
              
      end #module ClassMethods    
  end
end
