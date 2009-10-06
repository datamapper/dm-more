require 'stringex'

module DataMapper
  module Types
    class Slug < DataMapper::Type
      primitive String
      length    2000

      # Maximum length chosen because URI type is limited to 2000
      # characters, and a slug is a component of a URI, so it should
      # not exceed the maximum URI length either.

      def self.load(value, property)
        value
      end

      def self.dump(value, property)
        return if value.nil?

        if value.respond_to?(:to_str)
          escape(value.to_str)
        else
          raise ArgumentError, '+value+ must be nil or respond to #to_str'
        end
      end

      def self.escape(string)
        string.to_url
      end
    end # class Slug
  end # module Types
end # module DataMapper
