module DataMapper
  class Repository
    def count(model, property, options)
      query = if current_scope = model.send(:current_scope)
        current_scope.merge(options)
      else
        Query.new(self, model, options)
      end
      @adapter.count(self, property, query)
    end
  end
end
