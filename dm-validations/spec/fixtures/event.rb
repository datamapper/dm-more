# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures

      class Event
        #
        # Behaviors
        #

        include ::DataMapper::Resource

        #
        # Properties
        #

        property :id,   Serial
        property :name, String, :required => true

        property :starts_at, DateTime
        property :ends_at,   DateTime

        #
        # Validations
        #

        validates_with_method :starts_at, :method => :ensure_dates_order_is_correct

        #
        # API
        #

        def ensure_dates_order_is_correct
          if starts_at && ends_at && (starts_at <= ends_at)
            true
          else
            [false, "Start time cannot be after end time"]
          end
        end
      end # Event
    end # Fixtures
  end # Validate
end # DataMapper
