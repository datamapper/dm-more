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
        property :slug,       Slug
        property :body,       Text

        property :created_at,   DateTime
        property :updated_at,   DateTime
        property :published_at, DateTime

        #
        # Hooks
        #

        before :valid? do
          self.slug = self.title
        end
      end # Article

      Article.auto_migrate!
    end
  end
end
