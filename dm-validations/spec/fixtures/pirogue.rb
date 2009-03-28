# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class Pirogue
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,       Serial
        property :salesman, String, :default => 'Layfayette'

        #
        # Validations
        #

        validates_absent :salesman, :on => :sale
      end
    end
  end
end
