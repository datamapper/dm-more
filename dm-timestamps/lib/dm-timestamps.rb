require 'rubygems'

gem 'dm-core', '=0.9.0'
require 'data_mapper'

module DataMapper
  module Timestamp
    TIMESTAMP_PROPERTIES = {
      :updated_at => lambda { |r| r.updated_at   = DateTime.now },
      :updated_on => lambda { |r| r.updated_on   = Date.today   },
      :created_at => lambda { |r| r.created_at ||= DateTime.now },
      :created_on => lambda { |r| r.created_on ||= Date.today   },
    }

    private

    def set_timestamp_properties
      self.class.properties.slice(*TIMESTAMP_PROPERTIES.keys).compact.each do |property|
        TIMESTAMP_PROPERTIES[property.name][self]
      end
    end
  end # module Timestamp

  module Resource
    include Timestamp

    class << self
      included = instance_method(:included)

      define_method(:included) do |model|
        included.bind(self).call(model)
        model.before :save, :set_timestamp_properties
      end
    end
  end # module Timestamp
end
