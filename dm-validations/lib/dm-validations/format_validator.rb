#require File.dirname(__FILE__) + '/formats/email'

require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'formats/email'

module DataMapper
  module Validate

    class FormatValidator < GenericValidator

      FORMATS = {}
      include DataMapper::Validate::Format::Email

      def initialize(field_name, options = {}, &b)
        super(field_name, options)
        @field_name, @options = field_name, options
        @options[:allow_nil] = false unless @options.has_key?(:allow_nil)
      end

      def call(target)
        value = target.validation_property_value(@field_name)
        return true if @options[:allow_nil] && value.nil?

        validation = (@options[:as] || @options[:with])

        raise "No such predefined format '#{validation}'" if validation.is_a?(Symbol) && !FORMATS.has_key?(validation)
        validator = validation.is_a?(Symbol) ? FORMATS[validation][0] : validation

        field = DataMapper::Inflection.humanize(@field_name)
        error_message = @options[:message] || '%s has an invalid format'.t(field)

        valid = case validator
        when Proc   then validator.call(value)
        when Regexp then validator =~ value
        else raise UnknownValidationFormat, "Can't determine how to validate #{target.class}##{@field_name} with #{validator.inspect}"
        end

        unless valid
          error_message = @options[:message] || error_message || '%s is invalid'.t(field)
          error_message = error_message.call(field, value) if Proc === error_message
          add_error(target, error_message , @field_name)
        end

        return valid
      end

      #class UnknownValidationFormat < StandardError; end

    end # class FormatValidator

    module ValidatesFormat
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        
        # Validates the format of a field
        #
        def validates_format(*fields)
          opts = opts_from_validator_args(fields)
          add_validator_to_context(opts, fields, DataMapper::Validate::FormatValidator)
        end
      end # module ClassMethods
      
    end # module ValidatesFormat
  end # module Validate
end # module DataMapper
