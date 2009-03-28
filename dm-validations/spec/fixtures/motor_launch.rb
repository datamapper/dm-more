module DataMapper
  module Validate
    module Fixtures

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
    end
  end
end
