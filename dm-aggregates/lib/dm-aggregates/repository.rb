module DataMapper
  class Repository
    def count(model, options)
      query = if current_scope = model.send(:current_scope)
        current_scope.merge(options)
      else
        Query.new(self, model, options)
      end
      @adapter.count(self, query)
    end
  end
end
