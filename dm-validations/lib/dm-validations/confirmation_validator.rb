module DataMapper
  module Validate

    class ConfirmationValidator < GenericValidator

      def initialize(field_name, options = {})
        super
        @options = options
        @field_name, @confirm_field_name = field_name, (options[:confirm] || "#{field_name}_confirmation").to_sym
        @options[:allow_nil] = true unless @options.has_key?(:allow_nil)
      end

      def call(target)
        unless valid?(target)
          error_message = @options[:message] || '%s does not match the confirmation'.t(DataMapper::Inflection.humanize(@field_name))
          add_error(target, error_message , @field_name)
          return false
        end

        return true
      end

      def valid?(target)
        field_value = target.instance_variable_get("@#{@field_name}")
        return true if @options[:allow_nil] && field_value.nil?
        return false if !@options[:allow_nil] && field_value.nil?

        confirm_value = target.instance_variable_get("@#{@confirm_field_name}")
        field_value == confirm_value
      end

    end # class ConfirmationValidator

    module ValidatesIsConfirmed

      ##
      # Validates that the given attribute is confirmed by another attribute. Commonly 
      # used when you have password and password_confirmation attributes.
      # 
      # ==== Options
      #   :allow_nil => true/false (default is true)
      #   :confirm => the attribute that you want to validate against (default is firstattr_confirmation)
      #
      # ==== Example Usage
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
      #     validates_is_confirmed :password
      #     validates_is_confirmed :email, :confirm => :email_repeated
      # 
      #     # a call to valid? will return false unless:
      #     # password == password_confirmation
      #     # and
      #     # email == email_repeated
      #     
      def validates_is_confirmed(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::ConfirmationValidator)
      end

    end # module ValidatesIsConfirmed
  end # module Validate
end # module DataMapper
