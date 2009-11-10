module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class NumericValidator < GenericValidator

      def call(target)
        value = target.validation_property_value(field_name)
        return true if optional?(value)

        errors = []

        validate_with(integer_only? ? :integer : :numeric, value, errors)

        add_errors(target, errors)

        # if the number is invalid, skip further tests
        return false if errors.any?

        [ :gt, :lt, :gte, :lte, :eq, :ne ].each do |validation_type|
          validate_with(validation_type, value, errors)
        end

        add_errors(target, errors)

        errors.empty?
      end

      private

      def integer_only?
        options.fetch(:integer_only, false)
      end

      def value_as_string(value)
        case value
          when Float      then value.to_d.to_s('F')  # Avoid Scientific Notation in Float to_s
          when BigDecimal then value.to_s('F')
          else value.to_s
        end
      end

      def add_errors(target, errors)
        return if errors.empty?

        if options.key?(:message)
          add_error(target, options[:message], field_name)
        else
          errors.each do |error_message|
            add_error(target, error_message, field_name)
          end
        end
      end

      def validate_with(validation_type, value, errors)
        send("validate_#{validation_type}", value, errors)
      end

      def validate_with_comparison(value, cmp, expected, error_message_name, errors, negated = false)
        return if expected.nil?

        comparison = value.send(cmp, expected)
        return if negated ? !comparison : comparison

        errors << ValidationErrors.default_error_message(error_message_name, field_name, expected)
      end

      def validate_integer(value, errors)
        validate_with_comparison(value_as_string(value), :=~, /\A[+-]?\d+\z/, :not_an_integer, errors)
      end

      def validate_numeric(value, errors)
        precision = options[:precision]
        scale     = options[:scale]

        regexp = if precision && scale
          if precision > scale && scale == 0
            /\A[+-]?(?:\d{1,#{precision}}(?:\.0)?)\z/
          elsif precision > scale
            /\A[+-]?(?:\d{1,#{precision - scale}}|\d{0,#{precision - scale}}\.\d{1,#{scale}})\z/
          elsif precision == scale
            /\A[+-]?(?:0(?:\.\d{1,#{scale}})?)\z/
          else
            raise ArgumentError, "Invalid precision #{precision.inspect} and scale #{scale.inspect} for #{field_name} (value: #{value.inspect} #{value.class})"
          end
        else
          /\A[+-]?(?:\d+|\d*\.\d+)\z/
        end

        validate_with_comparison(value_as_string(value), :=~, regexp, :not_a_number, errors)
      end

      def validate_gt(value, errors)
        validate_with_comparison(value, :>, options[:gt], :greater_than, errors)
      end

      def validate_lt(value, errors)
        validate_with_comparison(value, :<, options[:lt], :less_than, errors)
      end

      def validate_gte(value, errors)
        validate_with_comparison(value, :>=, options[:gte], :greater_than_or_equal_to, errors)
      end

      def validate_lte(value, errors)
        validate_with_comparison(value, :<=, options[:lte], :less_than_or_equal_to, errors)
      end

      def validate_eq(value, errors)
        eq = options[:eq] || options[:equal] || options[:equals] || options[:exactly]
        validate_with_comparison(value, :==, eq, :equal_to, errors)
      end

      def validate_ne(value, errors)
        validate_with_comparison(value, :==, options[:ne], :not_equal_to, errors, true)
      end
    end # class NumericValidator

    module ValidatesIsNumber

      # Validate whether a field is numeric
      #
      # @details
      #
      # Options are:
      #
      # :allow_nil => true | false
      #   true if number can be nil, false if not
      #
      # :allow_blank => true | false
      #   true if number can be blank, false if not
      #
      # :message => "Error message for %s"
      #   Custom error message, also can be a callable object that takes
      #   an object (for pure Ruby objects) or object and property (for DM resources)
      #
      # :precision => 2
      #   Required precision of a value
      #
      # :scale => 2
      #   Required scale of a value
      #
      # :gte => 5.75
      #   'Greater than or greater' requirement
      #
      # :lte => 5.75
      #   'Less than or greater' requirement
      #
      # :lt => 5.75
      #   'Less than' requirement
      #
      # :gt => 5.75
      #   'Greater than' requirement
      #
      # :eq => 5.75
      #   'Equal' requirement
      #
      # :ne => 5.75
      #   'Not equal' requirement
      #
      # :integer_only => true
      #   Use to restrict allowed values to integers
      def validates_is_number(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::NumericValidator)
      end

    end # module ValidatesIsNumber
  end # module Validate
end # module DataMapper
