module DataMapper
  class Repository
    def count(model, property, query)
      adapter.count(self, property, scoped_query(model, query))
    end

    def min(model, property, query)
      adapter.min(self, property, scoped_query(model, query))
    end

    def max(model, property, query)
      adapter.max(self, property, scoped_query(model, query))
    end

    def avg(model, property, query)
      adapter.avg(self, property, scoped_query(model, query))
    end

    def sum(model, property, query)
      adapter.sum(self, property, scoped_query(model, query))
    end
  end
end
