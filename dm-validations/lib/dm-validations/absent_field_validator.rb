module DataMapper
  module Validate

    class AbsentFieldValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
      end

      def call(target)
        field_value = target.attribute_get(field_name).blank?
        return true if field_value

        error_message = @options[:message] || "%s must be absent".t(DataMapper::Inflection.humanize(@field_name))
        add_error(target, error_message , @field_name)

        return false
      end
    end # class AbsentFieldValidator

    module ValidatesAbsent
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        # Validate the absence of a field
        #
        def validates_absent(*fields)
          opts = opts_from_validator_args(fields)
          add_validator_to_context(opts, fields, DataMapper::Validate::AbsentFieldValidator)
        end
      end # module ClassMethods

    end # module ValidatesAbsent
  end # module Validate
end # module DataMapper
