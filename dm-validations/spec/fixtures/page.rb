# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures

      # see http://datamapper.lighthouseapp.com/projects/20609/tickets/671
      class Page
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,   Serial, :key      => true
        property :body, Text,   :nullable => false

        #
        # Validations
        #

        # duplicates inferred validation for body (caused by
        # :nullable => false)
        validates_present :body
      end
    end # Fixtures
  end # Validate
end # DataMapper
