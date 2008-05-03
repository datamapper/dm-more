module DataMapper
  module Resource
    module ClassMethods
      def count(options = {})
        repository(options[:repository]).count(self, options)
      end
    end
  end
end
