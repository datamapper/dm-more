module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class NumericValidator < GenericValidator

      def initialize(field_name, options={})
        super

        @options[:integer_only] = false unless @options.has_key?(:integer_only)
      end

      def call(target)
        value = target.send(field_name)
        return true if @options[:allow_nil] && value.blank?

        value = case value
          when Float      then BigDecimal.new(value.to_s).to_s('F') # Avoid Scientific Notation in Float to_s
          when BigDecimal then value.to_s('F')
          else value.to_s
        end

        error_message = @options[:message]
        precision     = @options[:precision]
        scale         = @options[:scale]
        eq            = @options[:eq] || @options[:equal] || @options[:equals] || @options[:exactly]
        gt            = @options[:gt]
        lt            = @options[:lt]
        ne            = @options[:ne]
        gte           = @options[:gte]
        lte           = @options[:lte]

        if @options[:integer_only]
          has_valid_number = true if value =~ /\A[+-]?\d+\z/
          error_message ||= ValidationErrors.default_error_message(:not_an_integer, field_name)
        else
          # FIXME: if precision and scale are not specified, can we assume that it is an integer?
          #        probably not, as floating point numbers don't have hard
          #        defined scale. the scale floats with the length of the
          #        integral and precision. Ie. if precision = 10 and integral
          #        portion of the number is 9834 (4 digits), the max scale will
          #        be 6 (10 - 4). But if the integral length is 1, max scale
          #        will be (10 - 1) = 9, so 1.234567890.
          #        In MySQL somehow you can hard-define scale on floats. Not
          #        quite sure how that works...
          if precision && scale
            # handles both Float when it has scale specified and BigDecimal
            if precision > scale && scale > 0
              has_valid_number = true if value =~ /\A[+-]?(?:\d{1,#{precision - scale}}|\d{0,#{precision - scale}}\.\d{1,#{scale}})\z/
            elsif precision > scale && scale == 0
              has_valid_number = true if value =~ /\A[+-]?(?:\d{1,#{precision}}(?:\.0)?)\z/
            elsif precision == scale
              has_valid_number = true if value =~ /\A[+-]?(?:0(?:\.\d{1,#{scale}})?)\z/
            else
              raise ArgumentError, "Invalid precision #{precision.inspect} and scale #{scale.inspect} for #{field_name} (value: #{value.inspect} #{value.class})"
            end
          elsif precision && scale.nil?
            # for floats, if scale is not set

            # total number of digits is less or equal precision
            has_valid_number = true if value.gsub(/[^\d]/, '').length <= precision

            # number of digits before decimal == precision, and the number is x.0. same as scale = 0
            has_valid_number = true if value =~ /\A[+-]?(?:\d{1,#{precision}}(?:\.0)?)\z/
          else
            has_valid_number = true if value =~ /\A[+-]?(?:\d+|\d*\.\d+)\z/
          end
          error_message ||= ValidationErrors.default_error_message(:not_a_number, field_name)
        end

        comparisons_pass = true
        if gt
          unless value.to_f > gt.to_f
            comparisons_pass         = false
            comparison_error_message = '%s must be a number greater than %s'.t(humanized_field_name, gt)
            add_error(target, comparison_error_message, @field_name)
          end
        end

        if lt
          unless value.to_f < lt.to_f
            comparisons_pass         = false
            comparison_error_message = '%s must be a number less than %s'.t(humanized_field_name, lt)
            add_error(target, comparison_error_message, @field_name)
          end
        end

        if gte
          unless value.to_f >= gte.to_f
            comparisons_pass         = false
            comparison_error_message = '%s must be a number greater than or equal to %s'.t(humanized_field_name, gte)
            add_error(target, comparison_error_message, @field_name)
          end
        end

        if lte
          unless value.to_f <= lte.to_f
            comparisons_pass         = false
            comparison_error_message = '%s must be a number less than or equal to %s'.t(humanized_field_name, lte)
            add_error(target, comparison_error_message, @field_name)
          end
        end

        if eq
          unless value.to_f == eq.to_f
            comparisons_pass         = false
            comparison_error_message = '%s must be a number equal to %s'.t(humanized_field_name, eq)
            add_error(target, comparison_error_message, @field_name)
          end
        end

        if ne
          unless value.to_f != ne.to_f
            comparisons_pass         = false
            comparison_error_message = '%s must be a number not equal to %s'.t(humanized_field_name, ne)
            add_error(target, comparison_error_message, @field_name)
          end
        end


        if has_valid_number && comparisons_pass
          return true
        else
          add_error(target, error_message, @field_name)
          return false
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
