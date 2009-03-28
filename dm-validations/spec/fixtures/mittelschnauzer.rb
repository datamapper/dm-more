module DataMapper
  module Validate
    module Fixtures
      class Mittelschnauzer

        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        without_auto_validations do
          property :name,   String, :key => true
          property :height, Float
        end

        #
        # Validations
        #

        validates_length :name, :min => 2, :allow_nil => false

        def self.valid_instance
          new(:name => "Roudolf Wilde")
        end
      end # Mittelschnauzer
    end
  end
end
