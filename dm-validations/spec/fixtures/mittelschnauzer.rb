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

        validates_is_number :height, :lt => 55.2

        def self.valid_instance
          new(:name => "Roudolf Wilde", :height => 50.4)
        end
      end # Mittelschnauzer
    end
  end
end
