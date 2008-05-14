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

    def min(model, property, options)
      query = if current_scope = model.send(:current_scope)
        current_scope.merge(options)
      else
        Query.new(self, model, options)
      end
      @adapter.min(self, property, query)
    end

    def max(model, property, options)
      query = if current_scope = model.send(:current_scope)
        current_scope.merge(options)
      else
        Query.new(self, model, options)
      end
      @adapter.max(self, property, query)
    end

    def avg(model, property, options)
      query = if current_scope = model.send(:current_scope)
        current_scope.merge(options)
      else
        Query.new(self, model, options)
      end
      @adapter.avg(self, property, query)
    end

    def sum(model, property, options)
      query = if current_scope = model.send(:current_scope)
        current_scope.merge(options)
      else
        Query.new(self, model, options)
      end
      @adapter.sum(self, property, query)
    end

  end
end
