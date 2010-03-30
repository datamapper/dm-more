# -*- coding: utf-8 -*-

module DataMapper
  module Validations
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

        validates_primitive_type_of :marked
        validates_primitive_type_of :color
      end
    end
  end
end
