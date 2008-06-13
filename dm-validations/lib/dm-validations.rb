require 'rubygems'
require 'pathname'

gem 'dm-core', '=0.9.2'
require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-validations'

require dir / 'validation_errors'
require dir / 'contextual_validators'
require dir / 'auto_validate'

require dir / 'generic_validator'
require dir / 'required_field_validator'
require dir / 'absent_field_validator'
require dir / 'confirmation_validator'
require dir / 'format_validator'
require dir / 'length_validator'
require dir / 'within_validator'
require dir / 'numeric_validator'
require dir / 'method_validator'
require dir / 'uniqueness_validator'
require dir / 'acceptance_validator'
require dir / 'custom_validator'

require dir / 'support' / 'object'

module DataMapper
  module Validate

    # Validate the resource before saving. Use #save! to save
    # the record without validations.
    #
    def save(context = :default)
      return false unless valid?(context)
      super()
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

    # Get the corresponding Resource property, if it exists.
    #
    # Note: DataMapper validations can be used on non-DataMapper resources.
    # In such cases, the return value will be nil.
    def validation_property(field_name)
      if DataMapper::Resource > self.class
        self.class.properties(self.repository.name)[field_name]
      end
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
      include DataMapper::Validate::ValidatesPresent
      include DataMapper::Validate::ValidatesAbsent
      include DataMapper::Validate::ValidatesIsConfirmed
      include DataMapper::Validate::ValidatesIsAccepted
      include DataMapper::Validate::ValidatesFormat
      include DataMapper::Validate::ValidatesLength
      include DataMapper::Validate::ValidatesWithin
      include DataMapper::Validate::ValidatesIsNumber
      include DataMapper::Validate::ValidatesWithMethod
      include DataMapper::Validate::ValidatesIsUnique
      include DataMapper::Validate::AutoValidate

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
      # requested context for each of the attributes in the fields list
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

    end # module ClassMethods
  end # module Validate

  module Resource
    class << self
      included = instance_method(:included)

      define_method(:included) do |model|
        included.bind(self).call(model)
        model.send(:alias_method, :save!, :save) unless model.method_defined? :save!
        model.send(:include, Validate)
      end
    end

    module ClassMethods
      include Validate::ClassMethods
    end # module ClassMethods
  end # module Resource
end # module DataMapper
