module DataMapper
  module Validate
    module Fixtures

      class Jabberwock
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,           Serial
        property :snickersnack, String

        #
        # Validations
        #

        validates_length :snickersnack, :within => 3..40, :message => "worble warble"
      end

      class MotorLaunch
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id, Serial
        property :name, String, :auto_validation => false
      end

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