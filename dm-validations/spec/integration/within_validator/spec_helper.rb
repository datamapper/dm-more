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

        validates_within :type_of_number, :set => %w(home work cell)
      end # PhoneNumber

      class MathematicalFunction
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,    Serial
        property :input,  Float, :auto_validation => false
        property :output, Float, :auto_validation => false

        #
        # Validations
        #

        # function domain
        # don't ask me what function that is
        validates_within :input,  :set => (1..n)

        # function range
        validates_within :output, :set => (-n..0), :message => "Negative values or zero only, please"
      end # MathematicalFunction
    end # Fixtures
  end # Validate
end # DataMapper
