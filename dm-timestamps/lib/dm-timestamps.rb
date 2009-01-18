require 'rubygems'

gem 'dm-core', '~>0.9.10'
require 'dm-core'

module DataMapper
  module Timestamp
    Resource.append_inclusions self

    TIMESTAMP_PROPERTIES = {
      :updated_at => [ DateTime, lambda { |r, p| DateTime.now                                    } ],
      :updated_on => [ Date,     lambda { |r, p| Date.today                                      } ],
      :created_at => [ DateTime, lambda { |r, p| r.created_at || (DateTime.now if r.new_record?) } ],
      :created_on => [ Date,     lambda { |r, p| r.created_on || (Date.today   if r.new_record?) } ],
    }.freeze

    def self.included(model)
      model.before :create, :set_timestamps
      model.before :update, :set_timestamps
      model.extend ClassMethods
    end

    private

    def set_timestamps
      return unless dirty? || new_record?
      TIMESTAMP_PROPERTIES.each do |name,(_type,proc)|
        if model.properties.has_property?(name)
          model.properties[name].set(self, proc.call(self, model.properties[name])) unless attribute_dirty?(name)
        end
      end
    end

    module ClassMethods
      def timestamps(*names)
        raise ArgumentError, 'You need to pass at least one argument' if names.empty?

        names.each do |name|
          case name
            when *TIMESTAMP_PROPERTIES.keys
              type = TIMESTAMP_PROPERTIES[name].first
              property name, type, :nullable => false, :auto_validation => false
            when :at
              timestamps(:created_at, :updated_at)
            when :on
              timestamps(:created_on, :updated_on)
            else
              raise InvalidTimestampName, "Invalid timestamp property name '#{name}'"
          end
        end
      end
    end # module ClassMethods

    class InvalidTimestampName < RuntimeError; end
  end # module Timestamp
  # include Timestamp or Timestamps, it still works
  Timestamps = Timestamp
end # module DataMapper
