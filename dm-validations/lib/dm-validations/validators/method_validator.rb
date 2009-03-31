module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class MethodValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @options[:method] = @field_name unless @options.has_key?(:method)
      end

      def call(target)
        result, message = target.send(@options[:method])
        add_error(target, message, field_name) unless result
        result
      end

      def ==(other)
        @options[:method] == other.instance_variable_get(:@options)[:method] && super
      end
    end # class MethodValidator

    module ValidatesWithMethod

      ##
      # Validate using the given method. The method must to return
      # either true, or a pair of [false, error message string]
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
      def validates_with_method(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::MethodValidator)
      end

    end # module ValidatesWithMethod
  end # module Validate
end # module DataMapper
