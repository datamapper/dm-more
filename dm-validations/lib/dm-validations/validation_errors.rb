module DataMapper
  module Validate

    ##
    #
    # @author Guy van den Berg
    # @since  0.9
    class ValidationErrors

      def initialize
        @errors = Hash.new { |h,k| h[k.to_sym] = [] }
      end

      # Clear existing validation errors.
      def clear!
        @errors.clear
      end

      # Add a validation error. Use the field_name :general if the errors does
      # not apply to a specific field of the Resource.
      #
      # @param <Symbol> field_name the name of the field that caused the error
      # @param <String> message    the message to add
      def add(field_name, message)
        @errors[field_name] << message
      end

      # Collect all errors into a single list.
      def full_messages
        @errors.inject([]) do |list,pair|
          list += pair.last
        end
      end

      # Return validation errors for a particular field_name.
      #
      # @param <Symbol> field_name the name of the field you want an error for
      def on(field_name)
        @errors[field_name].empty? ? nil : @errors[field_name]
      end

      def each
        @errors.map.each do |k,v|
          yield(v)
        end
      end

      def method_missing(meth, *args, &block)
        @errors.send(meth, *args, &block)
      end

    end # class ValidationErrors
  end # module Validate
end # module DataMapper
