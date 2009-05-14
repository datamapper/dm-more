module DataMapper
  class Collection
    alias original_all all

    def all(query={}, &block)
      query = DataMapper::Querizer.translate(&block) if block
      query = scoped_query(query)
      original_all(query)
    end
  end
end
