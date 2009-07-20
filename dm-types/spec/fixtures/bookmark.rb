module DataMapper
  module Types
    module Fixtures

      class Bookmark
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id, Serial

        property :title,  String, :length => 255
        property :shared, Boolean
        property :uri,    URI
        property :tags,   Yaml

        auto_migrate!
      end # Bookmark
    end
  end
end
