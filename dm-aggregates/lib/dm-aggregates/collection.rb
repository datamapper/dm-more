module DataMapper
  module Aggregates
    module Collection
      include Functions

#      def size
#        loaded? ? super : count
#      end

      private

      def property_by_name(property_name)
        properties[property_name]
      end
    end
  end
end
