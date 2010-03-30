module DataMapper
  module Validations

    ##
    #
    # @author Dirkjan Bussink
    # @since  0.9
    class PrimitiveTypeValidator < GenericValidator
      def call(target)
        value    = target.validation_property_value(field_name)
        property = target.validation_property(field_name)

        return true if value.nil? || property.primitive?(value)

        error_message = @options[:message] || default_error(property)
        add_error(target, error_message, field_name)

        false
      end

      protected

      def default_error(property)
        ValidationErrors.default_error_message(:primitive, field_name, property.primitive)
      end

    end # class PrimitiveTypeValidator

    module ValidatesPrimitiveType

      extend Deprecate

      ##
      # Validates that the specified attribute is of the correct primitive type.
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Person
      #     include DataMapper::Resource
      #
      #     property :birth_date, Date
      #
      #     validates_primitive_type_of :birth_date
      #
      #     # a call to valid? will return false unless
      #     # the birth_date is something that can be properly
      #     # casted into a Date object.
      #   end
      def validates_primitive_type_of(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validations::PrimitiveTypeValidator)
      end

      deprecate :validates_is_primitive, :validates_primitive_type_of

    end # module ValidatesPresent
  end # module Validations
end # module DataMapper
