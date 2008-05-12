require 'rubygems'
require 'addressable/uri'

module DataMapper
  module Types
    class Uri < DataMapper::Type
      primitive String
      
      def self.load(value, property)
        Addressable::URI.parse(value)
      end
  
      def self.dump(value, property)
        return nil if value.nil?
        value.to_s
      end
    end
  end
end