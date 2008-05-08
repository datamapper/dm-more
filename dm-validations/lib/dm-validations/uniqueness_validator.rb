module DataMapper
  module Validate
    class UniquenessValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @field_name, @options = field_name, options
      end

      def call(target)
        scope = @options.has_key?(:scope) ? @options[:scope] : nil
        scope = [scope] if !scope.nil? && scope.is_a?(Symbol)
        raise ArgumentError, '+scope+ must be a symbol or array of symbols' if scope && !scope.is_a?(Array)

        opts = {}
        opts[@field_name] = target.validation_property_value(@field_name)
        unless scope.nil?
          scope.map do |item|
            if !target.class.properties(target.repository.name)[item].nil?
              opts[item] = target.validation_property_value(item)
            elsif target.class.relationships.has_key?(item)
              target.validation_association_keys(item).map do |key|
                opts[key] = target.validation_property_value(key)
              end
            end
          end
        end

        resource = nil
        repository(target.repository.name) do
          resource = target.class.first(opts)
        end

        return true if resource.nil?
        # is target and found resource identic? same instance... but not ==
        return true if resource.class == target.class && resource.repository.name == target.repository.name && resource.key == target.key

        error_message = @options[:message] || "%s is already taken".t(DataMapper::Inflection.humanize(@field_name))
        add_error(target, error_message , @field_name)
        return false
      end
    end # class UniquenessValidator

    module ValidatesIsUnique
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

        # Validate the uniqueness of a field
        #
        def validates_is_unique(*fields)
          opts = opts_from_validator_args(fields)
          add_validator_to_context(opts, fields, DataMapper::Validate::UniquenessValidator)
        end
      end # module ClassMethods

    end # module ValidatesIsUnique
  end # module Validate
end # module DataMapper
