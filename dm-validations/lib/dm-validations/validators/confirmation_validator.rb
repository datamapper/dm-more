# -*- coding: utf-8 -*-
module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class ConfirmationValidator < GenericValidator

      def initialize(field_name, options = {})
        super

        set_optional_by_default

        @confirm_field_name  = (options[:confirm] || "#{field_name}_confirmation").to_sym
      end

      def call(target)
        return true if valid?(target)

        error_message = @options[:message] || ValidationErrors.default_error_message(:confirmation, field_name)
        add_error(target, error_message, field_name)

        false
      end

      private

      def valid?(target)
        value = target.validation_property_value(field_name)
        return true if optional?(value)

        if target.model.properties.named?(field_name)
          return true unless target.attribute_dirty?(field_name)
        end

        confirm_value = target.instance_variable_get("@#{@confirm_field_name}")
        value == confirm_value
      end
    end # class ConfirmationValidator

    module ValidatesIsConfirmed
      extend Deprecate

      ##
      # Validates that the given attribute is confirmed by another attribute.
      # A common use case scenario is when you require a user to confirm their
      # password, for which you use both password and password_confirmation
      # attributes.
      #
      # @option :allow_nil<Boolean>   true/false (default is true)
      # @option :allow_blank<Boolean> true/false (default is true)
      # @option :confirm<Symbol>      the attribute that you want to validate
      #                               against (default is firstattr_confirmation)
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :password, String
      #     property :email, String
      #     attr_accessor :password_confirmation
      #     attr_accessor :email_repeated
      #
      #     validates_confirmation_of :password
      #     validates_confirmation_of :email, :confirm => :email_repeated
      #
      #     # a call to valid? will return false unless:
      #     # password == password_confirmation
      #     # and
      #     # email == email_repeated
      #
      def validates_confirmation_of(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::ConfirmationValidator)
      end

      deprecate :validates_is_confirmed, :validates_confirmation_of

    end # module ValidatesIsConfirmed
  end # module Validate
end # module DataMapper
