module DataMapper
  module Types
    module Fixtures
      class Ticket
        #
        # Behaviors
        #

        include DataMapper::Resource
        include DataMapper::Validate

        #
        # Properties
        #

        property :id,     Serial
        property :title,  String, :length => 255
        property :body,   Text
        property :status, Enum[:unconfirmed, :confirmed, :assigned, :resolved, :not_applicable]

        auto_migrate!
      end # Ticket
    end
  end
end
