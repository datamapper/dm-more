require 'rubygems'
require 'data_mapper'

module DataMapper
  module Timestamp

    def self.included(base)
      base.class_eval do
        before :save, :update_magic_properties
        include InstanceMethods
      end
    end

    MAGIC_PROPERTIES = {
      :updated_at => lambda { self.updated_at = Time::now },
      :updated_on => lambda { self.updated_on = Date::today },
      :created_at => lambda { self.created_at ||= Time::now },
      :created_on => lambda { self.created_on ||= Date::today }
    }

    module InstanceMethods
      def update_magic_properties
        self.class.properties.each do |property|
          if MAGIC_PROPERTIES.has_key?(property.name)
            instance_eval(&MAGIC_PROPERTIES[property.name])
          end
        end
      end  
    end

  end
end
