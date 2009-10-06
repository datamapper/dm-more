module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class MethodValidator < GenericValidator

      def initialize(field_name, options={})
        super
        @options[:method] = @field_name unless @options.key?(:method)
      end

      def call(target)
        result, message = target.__send__(@options[:method])
        add_error(target, message, field_name) unless result
        result
      end

      def ==(other)
        @options[:method] == other.instance_variable_get(:@options)[:method] && super
      end
    end # class MethodValidator

    module ValidatesWithMethod

      ##
      # Validate using method called on validated object. The method must to return
      # either true, or a pair of [false, error message string], and is specified
      # as a symbol passed with :method option.
      #
      # This validator does support multiple fields being specified at a time,
      # but we encourage you to use it with one property/method at a time.
      #
      # Real world experience shows that method validation is often useful when
      # attribute needs to be virtual and not a property name.
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #  class Page
      #    include DataMapper::Resource
      #
      #    property :zip_code, String
      #
      #    validates_with_method :zip_code, :method => :in_the_right_location?
      #
      #    def in_the_right_location?
      #      if @zip_code == "94301"
      #        return true
      #      else
      #        return [false, "You're in the wrong zip code"]
      #      end
      #    end
      #
      #    # A call to valid? will return false and
      #    # populate the object's errors with "You're in the
      #    # wrong zip code" unless zip_code == "94301"
      #  end
      def validates_with_method(*fields)
        opts = opts_from_validator_args(fields)
        add_validator_to_context(opts, fields, DataMapper::Validate::MethodValidator)
      end

    end # module ValidatesWithMethod
  end # module Validate
end # module DataMapper
