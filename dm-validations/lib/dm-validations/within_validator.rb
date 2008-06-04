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
        includes = @options[:set].include?(target.attribute_get(field_name))
        return true if includes

        s = ''
        @options[:set].each {|item| s = s + "#{item}, "}
        s = '[' + s[0..(s.length-3)] + ']'

        error_message = @options[:message] || "%s must be one of #{s}".t(Extlib::Inflection.humanize(@field_name))
        add_error(target, error_message , @field_name)
        return false
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
