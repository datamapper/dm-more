module DataMapper
  module Types
    module Fixtures

      class Person
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,       Serial
        property :password, BCryptHash
      end

      Person.auto_migrate!
    end
  end
end
