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
        includes = @options[:set].include?(target.send(field_name))
        return true if includes

        if @options[:set].is_a?(Range)
          if @options[:set].first != -n && @options[:set].last != n
            message = "%s must be between #{@options[:set].first} and #{@options[:set].last}"
          elsif @options[:set].first == -n
            message = "%s must be less than #{@options[:set].last}"
          elsif @options[:set].last == n
            message = "%s must be greater than #{@options[:set].first}"
          end
        else
          message = "%s must be one of [#{ @options[:set].join(', ')}]"
        end

        error_message = @options[:message] || message.t(Extlib::Inflection.humanize(@field_name))
        add_error(target, error_message , @field_name)
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
