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
        property :uri,    URI
        property :tags,   Yaml
        property :shared, Boolean
      end # Bookmark

      Bookmark.auto_migrate!
    end
  end
end
