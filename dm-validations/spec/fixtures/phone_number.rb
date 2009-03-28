# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class PhoneNumber
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,             Serial
        property :type_of_number, String, :auto_validation => false

        #
        # Validations
        #

        validates_within :type_of_number, :set => %w(home work cell), :message => "Should be one of: home, cell or work"
      end # PhoneNumber
    end # Fixtures
  end # Validate
end # DataMapper
