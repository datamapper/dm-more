module DataMapper
  module Resource
    module ClassMethods
      def count(*args)
        with_repository_and_property(*args) do |repository,property,options|
          repository.count(self, property, options)
        end
      end

      def min(*args)
        with_repository_and_property(*args) do |repository,property,options|
          check_property_is_number(property)
          repository.min(self, property, options)
        end
      end

      def max(*args)
        with_repository_and_property(*args) do |repository,property,options|
          check_property_is_number(property)
          repository.max(self, property, options)
        end
      end

      def avg(*args)
        with_repository_and_property(*args) do |repository,property,options|
          check_property_is_number(property)
          repository.avg(self, property, options)
        end
      end

      def sum(*args)
        with_repository_and_property(*args) do |repository,property,options|
          check_property_is_number(property)
          repository.sum(self, property, options)
        end
      end

      # def first(*args)
      #   with_repository_and_property(*args) do |repository,property,options|
      #     raise NotImplementedError
      #   end
      # end
      #
      # def last(*args)
      #   with_repository_and_property(*args) do |repository,property,options|
      #     raise NotImplementedError
      #   end
      # end

      private

      def with_repository_and_property(*args, &block)
        options       = Hash === args.last ? args.pop : {}
        property_name = args.shift

        repository(options[:repository]) do |repository|
          property = properties(repository.name)[property_name] if property_name
          yield repository, property, options
        end
      end

      def check_property_is_number(property)
        raise ArgumentError, "+property+ should be an Integer, Float or BigDecimal, but was #{property.nil? ? 'nil' : property.type.class}" unless property && [ Fixnum, Float, BigDecimal ].include?(property.type)
      end

    end
  end
end
