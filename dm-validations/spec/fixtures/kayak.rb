# -*- coding: utf-8 -*-

module DataMapper
  module Validations
    module Fixtures
      class Kayak
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,       Serial
        property :salesman, String, :auto_validation => false

        #
        # Validations
        #

        validates_absence_of :salesman, :on => :sale
      end
    end
  end
end
