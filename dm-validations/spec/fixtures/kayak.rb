# -*- coding: utf-8 -*-

module DataMapper
  module Validate
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

        validates_absent :salesman, :on => :sale
      end
    end
  end
end
