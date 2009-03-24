module DataMapper
  class Property
    # for options_with_message
    PROPERTY_OPTIONS << :message << :messages << :set
  end

  module Validate
    module AutoValidate
      @disable_auto_validations = false

      # adds message for validator
      def options_with_message(base_options, property, validator_name)
        options = base_options.clone
        opts = property.options
        options[:message] = if opts[:messages] && opts[:messages].respond_to?(:[])
                              opts[:messages][validator_name]
                            elsif opts[:message]
                              opts[:message]
                            else
                              nil
                            end
        options
      end

      attr_reader :disable_auto_validations

      # disables generation of validations for
      # duration of given block
      def without_auto_validations(&block)
        @disable_auto_validations = true
        block.call
        @disable_auto_validations = false
      end

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
      #   :set => ["foo", "bar", "baz"]
      #       Setting the :set option causes a validates_within
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
      #
      #
      #   Messages
      #
      #   :messages => {..}
      #       Setting :messages hash replaces standard error messages
      #       with custom ones. For instance:
      #       :messages => {:presence => "Field is required",
      #                     :format => "Field has invalid format"}
      #       Hash keys are: :presence, :format, :length, :is_unique,
      #                      :is_number, :is_primitive
      #
      #   :message => "Some message"
      #       It is just shortcut if only one validation option is set
      #
      def auto_generate_validations(property)
        return if disabled_auto_validations? || skip_auto_validation_for?(property)

        # a serial property is allowed to be nil too, because the
        # value is set by the storage system
        opts = { :allow_nil => property.nullable? || property.serial? }
        opts[:context] = property.options[:validates] if property.options.has_key?(:validates)

        # presence
        unless opts[:allow_nil]
          # validates_present property.name, opts
          validates_present property.name, options_with_message(opts, property, :presence)
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
          # validates_length property.name, opts
          validates_length property.name, options_with_message(opts, property, :length)
        end

        # format
        if property.options.has_key?(:format)
          opts[:with] = property.options[:format]
          # validates_format property.name, opts
          validates_format property.name, options_with_message(opts, property, :format)
        end

        # uniqueness validator
        if property.options.has_key?(:unique)
          value = property.options[:unique]
          if value.is_a?(Array) || value.is_a?(Symbol)
            # validates_is_unique property.name, :scope => Array(value)
            validates_is_unique property.name, options_with_message({:scope => Array(value)}, property, :is_unique)
          elsif value.is_a?(TrueClass)
            # validates_is_unique property.name
            validates_is_unique property.name, options_with_message({}, property, :is_unique)
          end
        end

        # within validator
        if property.options.has_key?(:set)
          validates_within property.name, options_with_message({:set => property.options[:set]}, property, :within)
        end

        # numeric validator
        if Integer == property.type
          opts[:integer_only] = true
          # validates_is_number property.name, opts
          validates_is_number property.name, options_with_message(opts, property, :is_number)
        elsif BigDecimal == property.type || Float == property.type
          opts[:precision] = property.precision
          opts[:scale]     = property.scale
          # validates_is_number property.name, opts
          validates_is_number property.name, options_with_message(opts, property, :is_number)
        else
          # We only need this in the case we don't already
          # have a numeric validator, because otherwise
          # it will cause duplicate validation errors
          unless property.custom?
            # validates_is_primitive property.name, opts
            validates_is_primitive property.name, options_with_message(opts, property, :is_primitive)
          end
        end
      end # auto_generate_validations

      # Checks whether auto validations are currently
      # disabled (see +disable_auto_validations+ method
      # that takes a block)
      #
      # @return [TrueClass, FalseClass]
      #   true if auto validation is currently
      #   disabled
      def disabled_auto_validations?
        @disable_auto_validations
      end
      alias auto_validations_disabled? disabled_auto_validations?


      # Checks whether or not property should be auto validated.
      # It is the case for properties with :auto_validation option
      # given and it's value evaluates to true
      #
      # @return [TrueClass, FalseClass]
      #   true for properties with :auto_validation option that has positive value
      def skip_auto_validation_for?(property)
        property.options.has_key?(:auto_validation) && !property.options[:auto_validation]
      end
    end # module AutoValidate
  end # module Validate
end # module DataMapper
