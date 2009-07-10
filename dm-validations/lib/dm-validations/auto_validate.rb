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

        infer_presence_validation_for(property, opts.dup)
        infer_length_validation_for(property, opts.dup)
        infer_format_validation_for(property, opts.dup)
        infer_uniqueness_validation_for(property, opts.dup)
        infer_within_validation_for(property, opts.dup)
        infer_numeric_validation_for(property, opts.dup)
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
        property.options.has_key?(:auto_validation) && !property.options[:auto_validation]
      end

      def infer_presence_validation_for(property, options)
        unless property.nullable? || property.serial?
          # validates_present property.name, opts
          validates_present property.name, options_with_message(options, property, :presence)
        end
      end

      def infer_length_validation_for(property, options)
        if [String, DataMapper::Types::Text].include?(property.type)
          len = property.options.fetch(:length, property.options.fetch(:size, DataMapper::Property::DEFAULT_LENGTH))
          if len.is_a?(Range)
            options[:within] = len
          else
            options[:maximum] = len
          end

          validates_length property.name, options_with_message(options, property, :length)
        end
      end

      def infer_format_validation_for(property, options)
        if property.options.has_key?(:format)
          options[:with] = property.options[:format]
          validates_format property.name, options_with_message(options, property, :format)
        end
      end

      def infer_uniqueness_validation_for(property, options)
        if property.options.has_key?(:unique)
          value = property.options[:unique]
          if value.is_a?(Array) || value.is_a?(Symbol)
            validates_is_unique property.name, options_with_message({:scope => Array(value)}, property, :is_unique)
          elsif value.is_a?(TrueClass)
            validates_is_unique property.name, options_with_message({}, property, :is_unique)
          end
        end
      end

      def infer_within_validation_for(property, options)
        validates_within property.name, options_with_message({:set => property.options[:set]}, property, :within) if property.options.has_key?(:set)
      end

      def infer_numeric_validation_for(property, options)
        if Integer == property.type
          options[:integer_only] = true

          validates_is_number property.name, options_with_message(options, property, :is_number)
        elsif BigDecimal == property.type || Float == property.type
          options[:precision] = property.precision
          options[:scale]     = property.scale

          validates_is_number property.name, options_with_message(options, property, :is_number)
        else
          # We only need this in the case we don't already
          # have a numeric validator, because otherwise
          # it will cause duplicate validation errors
          validates_is_primitive property.name, options_with_message(options, property, :is_primitive) unless property.custom?
        end
      end
    end # module AutoValidate
  end # module Validate
end # module DataMapper
