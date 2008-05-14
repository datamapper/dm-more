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
          raise NotImplementedError
        end
      end

      def max(*args)
        with_repository_and_property(*args) do |repository,property,options|
          raise NotImplementedError
        end
      end

      def avg(*args)
        with_repository_and_property(*args) do |repository,property,options|
          raise NotImplementedError
        end
      end

      def sum(*args)
        with_repository_and_property(*args) do |repository,property,options|
          raise NotImplementedError
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
    end
  end
end
