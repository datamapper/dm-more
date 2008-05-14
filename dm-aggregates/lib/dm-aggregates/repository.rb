module DataMapper
  class Repository
    def count(model, property, options)
      @adapter.count(self, property, scoped_query(model, options))
    end

    def min(model, property, options)
      @adapter.min(self, property, scoped_query(model, options))
    end

    def max(model, property, options)
      @adapter.max(self, property, scoped_query(model, options))
    end

    def avg(model, property, options)
      @adapter.avg(self, property, scoped_query(model, options))
    end

    def sum(model, property, options)
      @adapter.sum(self, property, scoped_query(model, options))
    end

    private

    def scoped_query(model, options)
      if current_scope = model.send(:current_scope)
        current_scope.merge(options)
      else
        Query.new(self, model, options)
      end
    end
  end
end
