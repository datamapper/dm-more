module DataMapper
  module Model
    include Aggregates

    private

    def with_repository_and_property(*args, &block)
      query = args.last.respond_to?(:merge) ? args.pop : {}

      if query.kind_of?(Hash)
        if query.has_key?(:fields) && query[:fields].any?
          query[:unique] = true
          query[:order] ||= query[:fields]
        else
          query[:fields] = []
        end
      end

      property_name = args.first

      query      = scoped_query(query)
      repository = query.repository
      property   = properties(repository.name)[property_name] if property_name

      yield repository, property, query
    end
  end
end
