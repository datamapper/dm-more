module DataMapper
  module Types
    module Fixtures

      class NetworkNode
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,               Serial
        property :node_uuid,        String, :index => true
        property :ip_address,       IPAddress
        property :cidr_subnet_bits, Integer

        #
        # API
        #

        def runs_ipv6?
          self.ip_address.ipv6?
        end

        def runs_ipv4?
          self.ip_address.ipv4?
        end
      end # NetworkNode

      NetworkNode.auto_migrate!
    end # Fixtures
  end # Types
end # DataMapper
