require 'rubygems'
gem 'dm-core', '=0.9.0'
require 'data_mapper'

module DataMapper
  module Resource
    module ClassMethods
      def find_or_create(search_attributes, create_attributes = {})
        first(search_attributes) || create(search_attributes.merge(create_attributes))
      end
    end
  end
end
