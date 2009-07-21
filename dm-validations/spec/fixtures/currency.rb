module DataMapper
  module Validate
    module Fixtures
      class Currency

        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        without_auto_validations do
          property :name,   String, :length => 1..50, :key => true
          property :code,   String, :length => 3,     :unique_index => true
          property :symbol, String, :length => 1
        end

        #
        # Validations
        #

        validates_length :name,   :within => 1..50
        validates_length :code,   :is => 3
        validates_length :symbol, :is => 1

        def self.valid_instance(overrides = {})
          defaults = {
            :name   => 'United States Dollar',
            :code   => 'USD',
            :symbol => '$'
          }

          new(defaults.merge(overrides))
        end
      end # Barcode
    end
  end
end
