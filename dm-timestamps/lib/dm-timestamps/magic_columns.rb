module DataMapper
  module Timestamp
    module MagicColumns
      
      def self.include(base)
        base.extend(ClassMethods)
      end

      module ClassMethods

      end
    end
  end
end
