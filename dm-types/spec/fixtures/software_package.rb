module DataMapper
  module Types
    module Fixtures

      class SoftwarePackage
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id, Serial
        without_auto_validations do
          property :node_number, Integer, :index => true

          property :source_path,      FilePath
          property :destination_path, FilePath

          property :product,     String
          property :version,     String
          property :released_at, DateTime

          property :security_update,  Boolean

          property :installed_at,     DateTime
          property :installed_by,     String
        end

        auto_migrate!
      end # SoftwarePackage
    end # Fixtures
  end # Types
end # DataMapper
