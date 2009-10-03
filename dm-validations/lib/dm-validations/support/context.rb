module DataMapper
  module Validate

    # Module with validation context functionality.
    #
    # Contexts are implemented using a simple array based
    # stack that is thread local. The default context can be
    # altered by overwriting default_validation_context or
    # will default to :default
    #
    module Context

      # TODO: document
      # @api private
      def default_validation_context
        current_validation_context || :default
      end

      protected

      # Pushes given context on top of context stack and yields
      # given block, then pops the stack. During block execution
      # contexts previously pushed onto the stack have no effect.
      #
      # @api private
      def validation_context(context = default_validation_context)
        assert_valid_context(context)
        validation_context_stack << context
        begin
          yield
        ensure
          validation_context_stack.pop
        end
      end

      private

      # Initializes (if necessary) and returns current scope stack
      # @api private
      def validation_context_stack
        Thread.current[:dm_validations_context_stack] ||= []
      end

      # Returns the current validation context or nil if none has been pushed
      # @api private
      def current_validation_context
        context = validation_context_stack.last
        valid_context?(context) ? context : :default
      end

      # Return the contexts for the model
      #
      # @return [Hash]
      #   the hash of contexts for the model
      #
      # @api private
      def contexts
        model.validators.contexts
      end

      # Test if the context is valid for the model
      #
      # @param [Symbol] context
      #   the context to test
      #
      # @return [Boolean]
      #   true if the context is valid for the model
      #
      # @api private
      def valid_context?(context)
        contexts.empty? || contexts.key?(context)
      end

      # Assert that the context is valid for this model
      #
      # @param [Symbol] context
      #   the context to test
      #
      # @raise [InvalidContextError]
      #   raised if the context is not valid for this model
      #
      # @api private
      def assert_valid_context(context)
        unless valid_context?(context)
          raise InvalidContextError, "#{context} is an invalid context, known contexts are #{contexts.keys.inspect}"
        end
      end
    end

    include Context

  end
end
