module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class MethodValidator < GenericValidator

      def initialize(method_name, options={})
        super
        @method_name, @options = method_name, options
        @options[:integer_only] = false unless @options.has_key?(:integer_only)
      end

      def call(target)
        result,message = target.send(@method_name)
        add_error(target,message,@method_name) if !result
        result
      end

      def ==(other)
        @method_name == other.instance_variable_get(:@method_name) && super
      end
    end # class MethodValidator

    module ValidatesWithMethod

      ##
      # Validate using the given method. The method given needs to return:
      # [result::<Boolean>, Error Message::<String>]
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :zip_code, String
      #
      #     validates_with_method :in_the_right_location?
      #
      #     def in_the_right_location?
      #       if @zip_code == "94301"
      #         return true
      #       else
      #         return [false, "You're in the wrong zip code"]
      #       end
      #     end
      #
      #     # A call to valid? will return false and
      #     # populate the object's errors with "You're in the
      #     # wrong zip code" unless zip_code == "94301"
      #
      def validates_with_method(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::MethodValidator)
      end

    end # module ValidatesWithMethod
  end # module Validate
end # module DataMapper
