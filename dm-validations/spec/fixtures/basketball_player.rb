# -*- coding: utf-8 -*-

module DataMapper
  module Validations
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

        # precision and scale need to be defined for length to be validated
        validates_numericality_of :height, :weight, :precision => 10
      end
    end # Fixtures
  end # Validations
end # DataMapper
