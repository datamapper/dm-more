require 'json'

module DataMapper
  module Types
    class Json < DataMapper::Type
      primitive Text

      def self.load(value, property)
        if value.nil?
          nil
        elsif value.is_a?(String)
          ::JSON.load(value)
        else
          raise ArgumentError.new("+value+ of a property of JSON type must be nil or a String")
        end
      end

      def self.dump(value, property)
        if value.nil? || value.is_a?(String)
          value
        else
          ::JSON.dump(value)
        end
      end

      def self.typecast(value, property)
        if value.nil? || value.kind_of?(Array) || value.kind_of?(Hash)
          value
        else
          ::JSON.load(value.to_s)
        end
      end
    end # class Json
    JSON = Json
  end # module Types
end # module DataMapper
