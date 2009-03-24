# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures

      class UDPPacket
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,          Serial

        property :source_port,      Integer, :auto_validation => false
        property :destination_port, Integer, :auto_validation => false

        property :length,           Integer, :auto_validation => false
        property :checksum,         String,  :auto_validation => false
        # consider that there are multiple algorithms
        # available to the app, and it is allowed
        # to be chosed
        #
        # yes, to some degree, this is a made up
        # property ;)
        property :checksum_algorithm, String, :auto_validation => false
        property :data,               Text,   :auto_validation => false

        #
        # Volatile attributes
        #

        attr_accessor :underlying_ip_version

        #
        # Validations
        #

        validates_present :checksum_algorithm, :checksum, :if => Proc.new { |packet| packet.underlying_ip_version == 6 }, :message => "Checksum is mandatory when used with IPv6"
      end

    end # Fixtures
  end # Validate
end # DataMapper
