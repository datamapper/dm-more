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

        property :name,       String
        property :positions,  ::DataMapper::Types::Json
        property :inventions, ::DataMapper::Types::Yaml

        property :interests, ::DataMapper::Types::CommaSeparatedList
      end

      Person.auto_migrate!
    end
  end
end
