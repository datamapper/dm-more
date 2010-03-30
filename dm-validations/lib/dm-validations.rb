require 'dm-core'

begin

  require 'active_support/core_ext/class/attribute_accessors'
  require 'active_support/core_ext/object/blank'
  require 'active_support/ordered_hash'

  class Object
    # If receiver is callable, calls it and
    # returns result. If not, just returns receiver
    # itself
    #
    # @return [Object]
    def try_call(*args)
      if self.respond_to?(:call)
        self.call(*args)
      else
        self
      end
    end
  end

rescue LoadError

  require 'extlib/class'
  require 'extlib/dictionary'
  require 'extlib/blank'
  require 'extlib/try_dup'
  require 'extlib/object'

  module ActiveSupport
    OrderedHash = Dictionary
  end

end

require 'dm-validations/exceptions'
require 'dm-validations/validation_errors'
require 'dm-validations/contextual_validators'
require 'dm-validations/auto_validate'

require 'dm-validations/validators/generic_validator'
require 'dm-validations/validators/required_field_validator'
require 'dm-validations/validators/primitive_validator'
require 'dm-validations/validators/absent_field_validator'
require 'dm-validations/validators/confirmation_validator'
require 'dm-validations/validators/format_validator'
require 'dm-validations/validators/length_validator'
require 'dm-validations/validators/within_validator'
require 'dm-validations/validators/numeric_validator'
require 'dm-validations/validators/method_validator'
require 'dm-validations/validators/block_validator'
require 'dm-validations/validators/uniqueness_validator'
require 'dm-validations/validators/acceptance_validator'

require 'dm-validations/support/context'
require 'dm-validations/support/object'

module DataMapper
  module Validations

    Model.append_inclusions self

    extend Chainable

    def self.included(model)
      model.class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def self.create(attributes = {}, *args)
          resource = new(attributes)
          resource.save(*args)
          resource
        end
      RUBY

      # models that are non DM resources must get .validators
      # and other methods, too
      model.extend ClassMethods
    end

    # Ensures the object is valid for the context provided, and otherwise
    # throws :halt and returns false.
    #
    chainable do
      def save(context = default_validation_context)
        validation_context(context) { super() }
      end
    end

    chainable do
      def update(attributes = {}, context = default_validation_context)
        validation_context(context) { super(attributes) }
      end
    end

    chainable do
      def save_self(*)
        return false unless !dirty_self? || validation_context_stack.empty? || valid?(current_validation_context)
        super
      end
    end

    # Return the ValidationErrors
    #
    def errors
      @errors ||= ValidationErrors.new(self)
    end

    # Mark this resource as validatable. When we validate associations of a
    # resource we can check if they respond to validatable? before trying to
    # recursivly validate them
    #
    def validatable?
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
      klass = respond_to?(:model) ? model : self.class
      klass.validators.execute(context, self)
    end

    def validation_property_value(name)
      __send__(name) if respond_to?(name, true)
    end

    # Get the corresponding Resource property, if it exists.
    #
    # Note: DataMapper validations can be used on non-DataMapper resources.
    # In such cases, the return value will be nil.
    def validation_property(field_name)
      if respond_to?(:model) && (properties = model.properties(repository.name)) && properties.named?(field_name)
        properties[field_name]
      end
    end

    module ClassMethods
      include DataMapper::Validations::ValidatesPresence
      include DataMapper::Validations::ValidatesAbsence
      include DataMapper::Validations::ValidatesConfirmation
      include DataMapper::Validations::ValidatesPrimitiveType
      include DataMapper::Validations::ValidatesAcceptance
      include DataMapper::Validations::ValidatesFormat
      include DataMapper::Validations::ValidatesLength
      include DataMapper::Validations::ValidatesWithin
      include DataMapper::Validations::ValidatesNumericality
      include DataMapper::Validations::ValidatesWithMethod
      include DataMapper::Validations::ValidatesWithBlock
      include DataMapper::Validations::ValidatesUniqueness
      include DataMapper::Validations::AutoValidations

      # Return the set of contextual validators or create a new one
      #
      def validators
        @validators ||= ContextualValidators.new
      end

      def inherited(base)
        super
        validators.contexts.each do |context, validators|
          base.validators.context(context).concat(validators)
        end
      end

      private

      # Clean up the argument list and return a opts hash, including the
      # merging of any default opts. Set the context to default if none is
      # provided. Also allow :context to be aliased to :on, :when & group
      #
      def opts_from_validator_args(args, defaults = nil)
        opts = args.last.kind_of?(Hash) ? args.pop.dup : {}
        context = opts.delete(:group) || opts.delete(:on) || opts.delete(:when) || opts.delete(:context) || :default
        opts[:context] = Array(context)
        opts.update(defaults) unless defaults.nil?
        opts
      end

      # Given a new context create an instance method of
      # valid_for_<context>? which simply calls valid?(context)
      # if it does not already exist
      #
      def create_context_instance_methods(context)
        name = "valid_for_#{context.to_s}?"
        unless respond_to?(:resource_method_defined) ? resource_method_defined?(name) : instance_methods.include?(name)
          class_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{name}                          # def valid_for_signup?
              valid?(#{context.to_sym.inspect})  #   valid?(:signup)
            end                                  # end
          RUBY
        end
      end

      # Create a new validator of the given klazz and push it onto the
      # requested context for each of the attributes in the fields list
      # @param [Hash]          opts
      #    Options supplied to validation macro, example:
      #    {:context=>:default, :maximum=>50, :allow_nil=>true, :message=>nil}
      #
      # @param [Array<Symbol>] fields
      #    Fields given to validation macro, example:
      #    [:first_name, :last_name] in validates_presence_of :first_name, :last_name
      #
      # @param [Class] klazz
      #    Validator class, example: DataMapper::Validations::LengthValidator
      def add_validator_to_context(opts, fields, validator_class)
        fields.each do |field|
          validator = validator_class.new(field, opts.dup)

          opts[:context].each do |context|
            validator_contexts = validators.context(context)
            next if validator_contexts.include?(validator)
            validator_contexts << validator
            create_context_instance_methods(context)
          end
        end
      end
    end # module ClassMethods
  end # module Validations

  # Provide a const alias for backward compatibility with plugins
  # This is scheduled to go away though, definitely before 1.0
  Validate = Validations

end # module DataMapper
