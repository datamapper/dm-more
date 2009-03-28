module DataMapper
  module Validate
    module Fixtures
      class Barcode

        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        without_auto_validations do
          property :code, String, :key => true
        end

        #
        # Validations
        #

        validates_length :code, :max => 10

        def self.valid_instance
          new(:code => "3600029145")
        end
      end # Barcode
    end
  end
end
