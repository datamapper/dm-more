module DataMapper
  module Model
    def all(query={},&block)
      query = DataMapper::Querizer.translate(&block) if block
      query = scoped_query(query)
      query.repository.read_many(query)
     end
  end
end