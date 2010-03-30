# -*- coding: utf-8 -*-

module DataMapper
  module Validations
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
        property :body, Text,   :required => true

        #
        # Validations
        #

        # duplicates inferred validation for body (caused by
        # :required => true)
        validates_presence_of :body
      end
    end # Fixtures
  end # Validations
end # DataMapper
