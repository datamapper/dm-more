module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class UniquenessValidator < GenericValidator
      include Extlib::Assertions

      def initialize(field_name, options = {})
        assert_kind_of 'scope', options[:scope], Array, Symbol if options.has_key?(:scope)
        super

        @options[:allow_nil] = true unless @options.include?(:allow_nil)
      end

      def call(target)
        value = target.send(field_name)

        return true if @options[:allow_nil] && value.blank?

        opts = {
          :fields    => target.model.key,
          field_name => value,
        }

        Array(@options[:scope]).each { |subject| opts[subject] = target.send(subject) }

        resource = DataMapper.repository(target.repository.name) { target.model.first(opts) }

        return true if resource.nil?
        return true if target.saved? && resource.key == target.key

        error_message = @options[:message] || ValidationErrors.default_error_message(:taken, field_name)
        add_error(target, error_message, field_name)

        false
      end
    end # class UniquenessValidator

    module ValidatesIsUnique

      # Validate the uniqueness of a field
      #
      def validates_is_unique(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::UniquenessValidator)
      end

    end # module ValidatesIsUnique
  end # module Validate
end # module DataMapper
