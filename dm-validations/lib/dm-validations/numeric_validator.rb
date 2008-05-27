module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class NumericValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
        @options[:integer_only] = false unless @options.has_key?(:integer_only)
      end

      def call(target)
        value = target.attribute_get(field_name)
        return true if @options[:allow_nil] && value.nil?

        value = value.kind_of?(BigDecimal) ? value.to_s('F') : value.to_s

        error_message = @options[:message]
        scale         = @options[:scale]
        precision     = @options[:precision]

        if @options[:integer_only]
          return true if value =~ /\A[+-]?\d+\z/
          error_message ||= '%s must be an integer'.t(DataMapper::Inflection.humanize(@field_name))
        else
          if scale && precision
            if scale == precision
              return true if value =~ /\A[+-]?(?:0\.\d{1,#{precision}})\z/
            elsif precision == 0
              return true if value =~ /\A[+-]?(?:\d{1,#{scale}}(?:\.0)?)\z/
            else
              return true if value =~ /\A[+-]?(?:\d{1,#{scale - precision}}|\d{0,#{scale - precision}}\.\d{1,#{precision}})\z/
            end
          else
            return true if value =~ /\A[+-]?(?:\d+|\d*\.\d+)\z/
          end
          error_message ||= '%s must be a number'.t(DataMapper::Inflection.humanize(@field_name))
        end

        add_error(target, error_message, @field_name)

        # TODO: check the gt, gte, lt, lte, and eq options

        return false
      end
    end # class NumericValidator

    module ValidatesIsNumber

      # Validate whether a field is numeric
      #
      def validates_is_number(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::NumericValidator)
      end

    end # module ValidatesIsNumber
  end # module Validate
end # module DataMapper
