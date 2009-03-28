module DataMapper
  module Validate
    module Fixtures

      # for pedants: we refer to DIX Ethernet here
      class EthernetFrame

        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        attr_accessor :link_support_fragmentation

        # we have to have a key in a DM resource
        property :id, Serial

        without_auto_validations do
          property :destination_mac, String
          property :source_mac,      String
          property :ether_type,      String
          property :payload,         Text
          property :crc,             String
        end

        #
        # Validations
        #

        validates_length :destination_mac, :source_mac, :equals => 6
        validates_length :ether_type, :equals => 2
        validates_length :payload, :min => 46, :max => 1500, :unless => :link_support_fragmentation
        # :is is alias for :equal
        validates_length :crc, :is => 4

        def self.valid_instance
          # these are obvisouly not bits, and not in hexadecimal
          # format either, but give fixture models some slack
          attributes = {
            :destination_mac => "7b7d93",
            :source_mac      => "abe763",
            :ether_type      => "88",
            :payload         => "Imagine yourself a beautiful bag full of bits here",
            :crc             => "4132"
          }
          new(attributes)
        end
      end # EthernetFrame
    end
  end
end
