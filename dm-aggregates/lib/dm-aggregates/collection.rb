module DataMapper
  class Collection
    include Aggregates

    private

    def with_repository_and_property(*args, &block)
      query         = args.last.respond_to?(:merge) ? args.pop : {}
      property_name = args.first

      query      = scoped_query(query)
      repository = query.repository
      property   = properties[property_name] if property_name

      yield repository, property, query
    end
  end
end
