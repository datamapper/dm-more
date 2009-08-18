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
        validation_context_stack.last
      end

    end

    include Context

  end
end
