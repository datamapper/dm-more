module DataMapper
  module Aggregates
    module Repository
      def aggregate(query)
        adapter.aggregate(query)
      end
    end
  end
end
