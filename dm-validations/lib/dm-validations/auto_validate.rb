module DataMapper
  module Validate
    module AutoValidate

      ##
      # Auto-generate validations for a given property. This will only occur
      # if the option :auto_validation is either true or left undefined.
      #
      # @details [Triggers]
      #   Triggers that generate validator creation
      #
      #   :nullable => false
      #       Setting the option :nullable to false causes a
      #       validates_presence_of validator to be automatically created on
      #       the property
      #
      #   :size => 20 or :length => 20
      #       Setting the option :size or :length causes a validates_length_of
      #       validator to be automatically created on the property. If the
      #       value is a Integer the validation will set :maximum => value if
      #       the value is a Range the validation will set :within => value
      #
      #   :format => :predefined / lambda / Proc
      #       Setting the :format option causes a validates_format_of
      #       validator to be automatically created on the property
      #
      #   Integer type
      #       Using a Integer type causes a validates_is_number
      #       validator to be created for the property.  integer_only
      #       is set to true
      #
      #   BigDecimal or Float type
      #       Using a Integer type causes a validates_is_number
      #       validator to be created for the property.  integer_only
      #       is set to false, and precision/scale match the property
      def auto_generate_validations(property)
        property.options[:auto_validation] = true unless property.options.has_key?(:auto_validation)
        return unless property.options[:auto_validation]

        # a serial property is allowed to be nil too, because the
        # value is set by the storage system
        opts = { :allow_nil => property.nullable? || property.serial? }
        opts[:context] = property.options[:validates] if property.options.has_key?(:validates)

        # presence
        unless opts[:allow_nil]
          validates_present property.name, opts
        end

        # length
        if property.type == String
          #len = property.length  # XXX: maybe length should always return a Range, with the min defaulting to 1
          len = property.options.fetch(:length, property.options.fetch(:size, DataMapper::Property::DEFAULT_LENGTH))
          if len.is_a?(Range)
            opts[:within] = len
          else
            opts[:maximum] = len
          end
          validates_length property.name, opts
        end

        # format
        if property.options.has_key?(:format)
          opts[:with] = property.options[:format]
          validates_format property.name, opts
        end

        # uniqueness validator
        if property.options.has_key?(:unique)
          value = property.options[:unique]
          if value.is_a?(Array) || value.is_a?(Symbol)
            validates_is_unique property.name, :scope => Array(value)
          elsif value.is_a?(TrueClass)
            validates_is_unique property.name
          end
        end

        # numeric validator
        if Integer == property.type
          opts[:integer_only] = true
          validates_is_number property.name, opts
        elsif BigDecimal == property.type || Float == property.type
          opts[:precision] = property.precision
          opts[:scale]     = property.scale
          validates_is_number property.name, opts
        else
          # We only need this in the case we don't already
          # have a numeric validator, because otherwise
          # it will cause duplicate validation errors
          unless property.custom?
            validates_is_primitive property.name, opts
          end
        end
      end

    end # module AutoValidate
  end # module Validate
end # module DataMapper
