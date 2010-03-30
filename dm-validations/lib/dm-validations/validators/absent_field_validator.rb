module DataMapper
  module Validations

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class AbsenceValidator < GenericValidator
      def call(target)
        return true if target.validation_property_value(field_name).blank?

        error_message = self.options[:message] || ValidationErrors.default_error_message(:absent, field_name)
        add_error(target, error_message, field_name)

        false
      end
    end # class AbsenceValidator

    module ValidatesAbsence

      extend Deprecate

      ##
      # Validates that the specified attribute is "blank" via the attribute's
      # #blank? method.
      #
      # @note
      #   dm-core's support lib adds the #blank? method to many classes,
      # @see lib/dm-core/support/blank.rb (dm-core) for more information.
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :unwanted_attribute, String
      #     property :another_unwanted, String
      #     property :yet_again, String
      #
      #     validates_absence_of :unwanted_attribute
      #     validates_absence_of :another_unwanted, :yet_again
      #
      #     # a call to valid? will return false unless
      #     # all three attributes are blank
      #   end
      #
      def validates_absence_of(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validations::AbsenceValidator)
      end

      deprecate :validates_absent, :validates_absence_of

    end # module ValidatesAbsent
  end # module Validations
end # module DataMapper
