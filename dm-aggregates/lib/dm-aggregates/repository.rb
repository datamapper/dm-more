module DataMapper
  module Aggregates
    module Repository
      def aggregate(query)
        return [] unless query.valid?
        adapter.aggregate(query)
      end
    end
  end
end
