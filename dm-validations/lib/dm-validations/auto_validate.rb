module DataMapper
  class Property
    # for options_with_message
    OPTIONS << :message << :messages << :set
  end

  module Validate
    module AutoValidate
      @disable_auto_validations = false

      # adds message for validator
      def options_with_message(base_options, property, validator_name)
        options = base_options.clone
        opts    = property.options

        if opts.key?(:messages)
          options[:message] = opts[:messages][validator_name]
        elsif opts.key?(:message)
          options[:message] = opts[:message]
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
      #   :required => true
      #       Setting the option :required to true causes a
      #       validates_present validator to be automatically created on
      #       the property
      #
      #   :length => 20
      #       Setting the option :length causes a validates_length_of
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

        # all auto-validations (aside from presence) should skip
        # validation when the value is nil
        opts = { :allow_nil => true }

        if property.options.key?(:validates)
          opts[:context] = property.options[:validates]
        end

        infer_presence_validation_for(property, opts.dup)
        infer_length_validation_for(property, opts.dup)
        infer_format_validation_for(property, opts.dup)
        infer_uniqueness_validation_for(property, opts.dup)
        infer_within_validation_for(property, opts.dup)
        infer_type_validation_for(property, opts.dup)
      end # auto_generate_validations

      # Checks whether auto validations are currently
      # disabled (see +disable_auto_validations+ method
      # that takes a block)
      #
      # @return [TrueClass, FalseClass]
      #   true if auto validation is currently disabled
      #
      def disabled_auto_validations?
        @disable_auto_validations || false
      end

      alias auto_validations_disabled? disabled_auto_validations?

      # Checks whether or not property should be auto validated.
      # It is the case for properties with :auto_validation option
      # given and it's value evaluates to true
      #
      # @return [TrueClass, FalseClass]
      #   true for properties with :auto_validation option that has positive value
      def skip_auto_validation_for?(property)
        property.options.key?(:auto_validation) && !property.options[:auto_validation]
      end

      def infer_presence_validation_for(property, options)
        return if skip_presence_validation?(property)

        validates_present property.name, options_with_message(options, property, :presence)
      end

      def infer_length_validation_for(property, options)
        return unless [ String, DataMapper::Types::Text ].include?(property.type)

        case length = property.options.fetch(:length, DataMapper::Property::DEFAULT_LENGTH)
          when Range then options[:within]  = length
          else            options[:maximum] = length
        end

        validates_length property.name, options_with_message(options, property, :length)
      end

      def infer_format_validation_for(property, options)
        return unless property.options.key?(:format)

        options[:with] = property.options[:format]

        validates_format property.name, options_with_message(options, property, :format)
      end

      def infer_uniqueness_validation_for(property, options)
        return unless property.options.key?(:unique)

        case value = property.options[:unique]
          when Array, Symbol
            options[:scope] = Array(value)

            validates_is_unique property.name, options_with_message(options, property, :is_unique)
          when TrueClass
            validates_is_unique property.name, options_with_message(options, property, :is_unique)
        end
      end

      def infer_within_validation_for(property, options)
        return unless property.options.key?(:set)

        options[:set] = property.options[:set]

        validates_within property.name, options_with_message(options, property, :within)
      end

      def infer_type_validation_for(property, options)
        options[:gte] = property.min if property.min
        options[:lte] = property.max if property.max

        if Integer == property.type
          options[:integer_only] = true

          validates_is_number property.name, options_with_message(options, property, :is_number)
        elsif BigDecimal == property.type || Float == property.type
          options[:precision] = property.precision
          options[:scale]     = property.scale

          validates_is_number property.name, options_with_message(options, property, :is_number)
        elsif !property.custom?
          # We only need this in the case we don't already
          # have a numeric validator, because otherwise
          # it will cause duplicate validation errors
          validates_is_primitive property.name, options_with_message(options, property, :is_primitive)
        end
      end

      private

      def skip_presence_validation?(property)
        property.allow_blank? || property.serial?
      end
    end # module AutoValidate
  end # module Validate
end # module DataMapper
