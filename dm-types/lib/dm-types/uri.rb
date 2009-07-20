require 'addressable/uri'

module DataMapper
  module Types
    class URI < DataMapper::Type
      primitive String
      length    2000

      # Maximum length chosen based on recommendation:
      # http://stackoverflow.com/questions/417142/what-is-the-maximum-length-of-an-url

      def self.load(value, property)
        Addressable::URI.parse(value)
      end

      def self.dump(value, property)
        value.to_s unless value.nil?
      end

      def self.typecast(value, property)
        load(value, property)
      end
    end # class URI
  end # module Types
end # module DataMapper
