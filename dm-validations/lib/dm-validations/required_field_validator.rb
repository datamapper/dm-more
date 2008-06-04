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
        value = target.validation_property_value(@field_name)
        return true if !value.blank?

        error_message = @options[:message] || "%s must not be blank".t(Extlib::Inflection.humanize(@field_name))
        add_error(target, error_message , @field_name)

        return false
      end

    end # class RequiredFieldValidator

    module ValidatesPresent

      ##
      # Validates that the specified attribute is "not blank" via the
      # attribute's #blank? method.
      #
      # @note
      #   dm-core's support lib adds the blank? method to many classes,
      # @see lib/data_mapper/support/blank.rb (dm-core) for more information.
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :required_attribute, String
      #     property :another_required, String
      #     property :yet_again, String
      #
      #     validates_present :required_attribute
      #     validates_present :another_required, :yet_again
      #
      #     # a call to valid? will return false unless
      #     # all three attributes are !blank?
      #   end
      def validates_present(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::RequiredFieldValidator)
      end

    end # module ValidatesPresent
  end # module Validate
end # module DataMapper
