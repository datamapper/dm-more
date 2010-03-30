module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class UniquenessValidator < GenericValidator
      include DataMapper::Assertions

      def initialize(field_name, options = {})
        assert_kind_of 'scope', options[:scope], Array, Symbol if options.has_key?(:scope)
        super

        set_optional_by_default
      end

      def call(target)
        return true if valid?(target)

        error_message = @options[:message] || ValidationErrors.default_error_message(:taken, field_name)
        add_error(target, error_message, field_name)

        false
      end

      def valid?(target)
        value = target.validation_property_value(field_name)
        return true if optional?(value)

        opts = {
          :fields    => target.model.key,
          field_name => value,
        }

        Array(@options[:scope]).each { |subject| opts[subject] = target.__send__(subject) }

        resource = DataMapper.repository(target.repository.name) { target.model.first(opts) }

        return true if resource.nil?

        target.saved? && resource.key == target.key
      end
    end # class UniquenessValidator

    module ValidatesUniqueness
      extend Deprecate

      # Validate the uniqueness of a field
      #
      def validates_uniqueness_of(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::UniquenessValidator)
      end

      deprecate :validates_is_unique, :validates_uniqueness_of

    end # module ValidatesIsUnique
  end # module Validate
end # module DataMapper
