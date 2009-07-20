module DataMapper
  module Types
    module Fixtures

      class Article
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,         Serial

        property :title,      String, :length => 255
        property :body,       Text

        property :created_at,   DateTime
        property :updated_at,   DateTime
        property :published_at, DateTime

        property :slug, Slug

        #
        # Hooks
        #

        before :valid? do
          self.slug = self.title
        end

        auto_migrate!
      end # Article
    end
  end
end
