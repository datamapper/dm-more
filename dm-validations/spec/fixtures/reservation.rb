# -*- coding: utf-8 -*-

module DataMapper
  module Validations
    module Fixtures
      class Reservation
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Attributes
        #

        attr_accessor :person_name_confirmation, :seats_confirmation

        #
        # Properties
        #

        property :id,              Serial
        property :person_name,     String,  :auto_validation => false
        property :number_of_seats, Integer, :auto_validation => false

        #
        # Validations
        #

        validates_confirmation_of :person_name,     :allow_nil => false, :allow_blank => false
        validates_confirmation_of :number_of_seats, :confirm => :seats_confirmation, :message => Proc.new { |resource, property|
          '%s requires confirmation for %s' % [ActiveSupport::Inflector.demodulize(resource.model.name), property.name]
        }
      end # Reservation
    end # Fixtures
  end # Validations
end # DataMapper
