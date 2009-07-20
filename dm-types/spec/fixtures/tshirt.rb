module DataMapper
  module Types
    module Fixtures

      class TShirt
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,          Serial
        property :writing,     String
        property :has_picture, Boolean, :default => false
        property :picture,     Enum[:octocat, :fork_you, :git_down]

        property :color, Enum[:white, :black, :red, :orange, :yellow, :green, :cyan, :blue, :purple]
        property :size,  Flag[:xs, :small, :medium, :large, :xl, :xxl]

        auto_migrate!
      end # Shirt
    end # Fixtures
  end # Types
end # DataMapper
