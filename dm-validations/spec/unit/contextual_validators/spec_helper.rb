# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures

      class PieceOfSoftware
        #
        # Behaviors
        #

        include DataMapper::Validate

        #
        # Attributes
        #

        attr_accessor :name, :operating_system

        #
        # Validations
        #

        #
        # API
        #

        def initialize(attributes = {})
          attributes.each do |key, value|
            self.send("#{key}=", value)
          end
        end
      end

    end # Fixtures
  end # Validate
end # DataMapper
