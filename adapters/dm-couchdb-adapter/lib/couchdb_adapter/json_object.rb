require 'json'

# Non-lazy objects that serialize to/from JSON, for use with couchdb
module DataMapper
  module Types
    class JsonObject < DataMapper::Type
      primitive String
      size 65535

      def self.load(value, property)
        if value.nil?
          nil
        elsif value.is_a?(String)
          ::JSON.load(value)
        else
          raise ArgumentError.new("+value+ must be nil or a String")
        end
      end

      def self.dump(value, property)
        if value.nil?
          nil
        elsif value.is_a?(String)
          value
        else
          ::JSON.dump(value)
        end
      end

      def self.typecast(value, property)
        value
      end
    end # class JsonObject
  end # module Types
end # module DataMapper
