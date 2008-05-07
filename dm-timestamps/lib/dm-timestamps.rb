require 'rubygems'

gem 'dm-core', '=0.9.0'
require 'data_mapper'

module DataMapper
  module Timestamp
    def self.included(base)
      base.before(:save, :update_timestamp_properties)
    end

    TIMESTAMP_PROPERTIES = {
      :updated_at => lambda { |r| r.updated_at   = DateTime.now },
      :updated_on => lambda { |r| r.updated_on   = Date.today   },
      :created_at => lambda { |r| r.created_at ||= DateTime.now },
      :created_on => lambda { |r| r.created_on ||= Date.today   },
    }

    private

    def update_timestamp_properties
      self.class.properties.slice(*TIMESTAMP_PROPERTIES.keys).each do |property|
        TIMESTAMP_PROPERTIES[property.name][self]
      end
    end
  end
end
