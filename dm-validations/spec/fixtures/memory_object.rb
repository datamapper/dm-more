# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class MemoryObject
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,     Serial
        property :marked, Boolean, :auto_validation => false
        property :color,  String,  :auto_validation => false

        #
        # Validations
        #

        validates_is_primitive :marked
        validates_is_primitive :color
      end
    end
  end
end
