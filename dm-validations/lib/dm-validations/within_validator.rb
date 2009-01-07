module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class WithinValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
        @options[:set] = [] unless @options.has_key?(:set)
      end

      def call(target)
        value = target.send(field_name)
        return true if @options[:allow_nil] && value.nil?
        return true if @options[:set].include?(value)

        if @options[:set].is_a?(Range)
          if @options[:set].first != -n && @options[:set].last != n
            error_message = @options[:message] || ValidationErrors.default_error_message(:value_between, field_name, @options[:set].first, @options[:set].last)
          elsif @options[:set].first == -n
            error_message = @options[:message] || ValidationErrors.default_error_message(:less_than_or_equal_to, field_name, @options[:set].last)
          elsif @options[:set].last == n
            error_message = @options[:message] || ValidationErrors.default_error_message(:greater_than_or_equal_to, field_name, @options[:set].first)
          end
        else
          error_message = ValidationErrors.default_error_message(:inclusion, field_name, @options[:set].join(', '))
        end

        add_error(target, error_message, field_name)
        return false
      end

      def n
        1.0/0
      end
    end # class WithinValidator

    module ValidatesWithin

      # Validate the absence of a field
      #
      def validates_within(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::WithinValidator)
      end

    end # module ValidatesWithin
  end # module Validate
end # module DataMapper
