module DataMapper
  class Repository
    # This accepts a ferret query string and an optional limit argument
    # which defaults to all. This is the proper way to perform searches more
    # complicated than DM's query syntax can handle (such as OR searches).
    # 
    # See DataMapper::Adapters::FerretAdapter#search for information on
    # the return value.
    def search(query, limit = :all)
      adapter.search(query, limit)
    end
  end
end