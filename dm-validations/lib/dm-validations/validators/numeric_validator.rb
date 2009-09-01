module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class NumericValidator < GenericValidator

      def initialize(field_name, options={})
        super

        @options[:integer_only] = false unless @options.key?(:integer_only)
      end

      def call(target)
        value = target.send(field_name)
        return true if @options[:allow_nil] && value.blank?

        value_string = case value
          when Float      then value.to_d.to_s('F') # Avoid Scientific Notation in Float to_s
          when BigDecimal then value.to_s('F')
          else value.to_s
        end

        custom_error_message = @options[:message]
        errors               = []

        if @options[:integer_only]
          unless value_string =~ /\A[+-]?\d+\z/
            errors << ValidationErrors.default_error_message(:not_an_integer, field_name)
          end
        else
          precision = @options[:precision]
          scale     = @options[:scale]

          # FIXME: if precision and scale are not specified, can we assume that it is an integer?
          #        probably not, as floating point numbers don't have hard
          #        defined scale. the scale floats with the length of the
          #        integral and precision. Ie. if precision = 10 and integral
          #        portion of the number is 9834 (4 digits), the max scale will
          #        be 6 (10 - 4). But if the integral length is 1, max scale
          #        will be (10 - 1) = 9, so 1.234567890.
          #        In MySQL somehow you can hard-define scale on floats. Not
          #        quite sure how that works...
          has_valid_number = if precision && scale
            # handles both Float when it has scale specified and BigDecimal
            regexp = if precision > scale && scale > 0
              /\A[+-]?(?:\d{1,#{precision - scale}}|\d{0,#{precision - scale}}\.\d{1,#{scale}})\z/
            elsif precision > scale && scale == 0
              /\A[+-]?(?:\d{1,#{precision}}(?:\.0)?)\z/
            elsif precision == scale
              /\A[+-]?(?:0(?:\.\d{1,#{scale}})?)\z/
            else
              raise ArgumentError, "Invalid precision #{precision.inspect} and scale #{scale.inspect} for #{field_name} (value: #{value.inspect} #{value.class})"
            end

            value_string =~ regexp
          elsif precision && scale.nil?
            # number of digits before decimal == precision, and the number is x.0. same as scale = 0
            value_string =~ /\A[+-]?(?:\d{1,#{precision}}(?:\.0)?)\z/
          else
            value_string =~ /\A[+-]?(?:\d+|\d*\.\d+)\z/
          end

          unless has_valid_number
            errors << ValidationErrors.default_error_message(:not_a_number, field_name)
          end
        end

        add_errors(target, errors, custom_error_message)

        return false if errors.any?

        if gt = @options[:gt]
          unless value > gt
            errors << ValidationErrors.default_error_message(:greater_than, field_name, gt)
          end
        end

        if lt = @options[:lt]
          unless value < lt
            errors << ValidationErrors.default_error_message(:less_than, field_name, lt)
          end
        end

        if gte = @options[:gte]
          unless value >= gte
            errors << ValidationErrors.default_error_message(:greater_than_or_equal_to, field_name, gte)
          end
        end

        if lte = @options[:lte]
          unless value <= lte
            errors << ValidationErrors.default_error_message(:less_than_or_equal_to, field_name, lte)
          end
        end

        if eq = @options[:eq] || @options[:equal] || @options[:equals] || @options[:exactly]
          unless value == eq
            errors << ValidationErrors.default_error_message(:equal_to, field_name, eq)
          end
        end

        if ne = @options[:ne]
          unless value != ne
            errors << ValidationErrors.default_error_message(:not_equal_to, field_name, ne)
          end
        end

        add_errors(target, errors, custom_error_message)

        errors.empty?
      end

      private

      def add_errors(target, errors, custom_error_message)
        return if errors.empty?

        if custom_error_message
          add_error(target, custom_error_message, field_name)
        else
          errors.each do |error_message|
            add_error(target, error_message, field_name)
          end
        end
      end
    end # class NumericValidator

    module ValidatesIsNumber

      # Validate whether a field is numeric
      #
      # @details
      #
      # Options are:
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
