module DataMapper
  module Model
    alias original_all all

    def all(query={}, &block)
      query = DataMapper::Querizer.translate(&block) if block
      query = scoped_query(query)
      original_all(query)
    end

    alias original_first first

    def first(*args)
      query = DataMapper::Querizer.translate(args.pop) if args.last.is_a? Proc
      query = args.last.respond_to?(:merge) ? args.pop : {}
      query = scoped_query(query.merge(:limit => args.first || 1))

      original_first(*(args << query))
    end
  end
end
