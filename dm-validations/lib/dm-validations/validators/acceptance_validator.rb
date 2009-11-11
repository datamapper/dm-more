module DataMapper
  module Validate

    ##
    #
    # @author Martin Kihlgren
    # @since  0.9
    class AcceptanceValidator < GenericValidator

      def initialize(field_name, options = {})
        super

        @options[:allow_nil] = true unless @options.key?(:allow_nil)

        @options[:accept] ||= [ '1', 1, 'true', true, 't' ]
        @options[:accept] = Array(@options[:accept])
      end

      def call(target)
        return true if valid?(target)

        error_message = @options[:message] || ValidationErrors.default_error_message(:accepted, field_name)
        add_error(target, error_message, field_name)

        false
      end

      private

      def valid?(target)
        value = target.validation_property_value(field_name)
        return true if allow_nil?(value)
        @options[:accept].include?(value)
      end
    end # class AcceptanceValidator

    module ValidatesIsAccepted

      ##
      # Validates that the attributes's value is in the set of accepted values.
      #
      # @option :allow_nil<Boolean> true if nil is allowed, false if not
      #                             allowed. Default is true.
      # @option :accept<Array>      a list of accepted values.
      #                             Default are ["1", 1, "true", true, "t"]).
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :license_agreement_accepted, String
      #     property :terms_accepted, String
      #     validates_is_accepted :license_agreement, :accept => "1"
      #     validates_is_accepted :terms_accepted, :allow_nil => false
      #
      #     # a call to valid? will return false unless:
      #     # license_agreement is nil or "1"
      #     # and
      #     # terms_accepted is one of ["1", 1, "true", true, "t"]
      #
      def validates_is_accepted(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::AcceptanceValidator)
      end

    end # module ValidatesIsAccepted
  end # module Validate
end # module DataMapper
