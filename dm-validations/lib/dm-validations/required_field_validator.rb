module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class RequiredFieldValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
      end

      def call(target)
        if @field_name == 'customer'
          puts @field_name
        end
        value = target.validation_property_value(@field_name)
        return true if !value.blank?

        error_message = @options[:message] || "%s must not be blank".t(DataMapper::Inflection.humanize(@field_name))
        add_error(target, error_message , @field_name)

        return false
      end

    end # class RequiredFieldValidator

    module ValidatesPresent

      # Validate the presence of a field
      #
      def validates_present(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::RequiredFieldValidator)
      end

    end # module ValidatesPresent
  end # module Validate
end # module DataMapper
