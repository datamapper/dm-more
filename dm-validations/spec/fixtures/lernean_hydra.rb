# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class LerneanHydra
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,     Serial

        without_auto_validations do
          property :head_count, Float
        end

        #
        # Validations
        #

        validates_is_number :head_count, :eq => 9, :message => "Lernean hydra is said to have exactly 9 heads"

        def self.valid_instance(overrides = {})
          defaults = {
            :head_count => 9
          }

          new(defaults.merge(overrides))
        end
      end
    end # Fixtures
  end # Validate
end # DataMapper
