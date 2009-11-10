module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class WithinValidator < GenericValidator

      def initialize(field_name, options={})
        super

        @options[:set] = [] unless @options.has_key?(:set)
      end

      def call(target)
        value = target.validation_property_value(field_name)
        return true if optional?(value)
        return true if @options[:set].include?(value)

        set = @options[:set]
        msg = @options[:message]
        if set.is_a?(Range)
          if set.first != -n && set.last != n
            error_message = msg || ValidationErrors.default_error_message(:value_between, field_name, set.first, set.last)
          elsif set.first == -n
            error_message = msg || ValidationErrors.default_error_message(:less_than_or_equal_to, field_name, set.last)
          elsif set.last == n
            error_message = msg || ValidationErrors.default_error_message(:greater_than_or_equal_to, field_name, set.first)
          end
        else
          error_message = msg || ValidationErrors.default_error_message(:inclusion, field_name, set.join(', '))
        end

        add_error(target, error_message, field_name)

        false
      end

      def n
        1.0/0
      end
    end # class WithinValidator

    module ValidatesWithin

      # Validate that value of a field if within a range/set
      #
      def validates_within(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::WithinValidator)
      end

    end # module ValidatesWithin
  end # module Validate
end # module DataMapper
