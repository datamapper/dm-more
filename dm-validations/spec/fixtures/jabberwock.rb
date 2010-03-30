module DataMapper
  module Validations
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

        validates_length_of :snickersnack, :within => 3..40, :message => "worble warble"
      end # Jabberwock
    end
  end
end
