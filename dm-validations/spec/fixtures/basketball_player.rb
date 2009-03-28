# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class BasketballPlayer
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
          property :height, Float
          property :weight, Float
        end

        #
        # Validations
        #

        validates_is_number :height, :weight
      end
      BasketballPlayer.auto_migrate!


    end # Fixtures
  end # Validate
end # DataMapper
