# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class BasketballCourt
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,     Serial

        without_auto_validations do
          property :name,   String

          property :length, Float
          property :width,  Float

          property :three_point_line_distance,  Float
          property :free_throw_line_distance,   Float
          property :rim_height,                 Float
        end

        #
        # Validations
        #

        # obviously these are all metrics
        validates_is_number :length, :gte => 15.0,  :lte => 15.24
        validates_is_number :width,  :gte => 25.28, :lte => 28.65

        # 3 pt line distance may use :gte and :lte, but for
        # sake of spec example we make it up a little
        validates_is_number :three_point_line_distance, :gt => 6.7, :lt => 7.24
        validates_is_number :free_throw_line_distance,  :equals => 4.57
        validates_is_number :rim_height,                :eq     => 3.05

        def self.valid_instance(overrides = {})
          defaults = {
            :length                    => 15.24,
            :width                     => 28.65,
            :free_throw_line_distance  => 4.57,
            :rim_height                => 3.05,
            :three_point_line_distance => 6.9
          }

          new(defaults.merge(overrides))
        end
      end
    end # Fixtures
  end # Validate
end # DataMapper
