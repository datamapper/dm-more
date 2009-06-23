module DataMapper
  module Types
    class Regexp < DataMapper::Type
      primitive String

      def self.load(value, property)
        ::Regexp.new(value) unless value.nil?
      end

      def self.dump(value, property)
        value.source unless value.nil?
      end

      def self.typecast(value, property)
        load(value, property)
      end
    end
  end
end
