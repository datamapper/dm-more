module DataMapper
  module Validate
    module Fixtures
      class BoatDock
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id, Serial
        property :name, String, :auto_validation => false, :default => "I'm a long string"

        #
        # Validations
        #

        validates_length :name, :min => 3
      end
    end
  end
end
