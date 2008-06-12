module DataMapper
  class Repository
    def count(property, query)
      adapter.count(property, query)
    end

    def min(property, query)
      adapter.min(property, query)
    end

    def max(property, query)
      adapter.max(property, query)
    end

    def avg(property, query)
      adapter.avg(property, query)
    end

    def sum(property, query)
      adapter.sum(property, query)
    end
  end
end
