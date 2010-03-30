# -*- coding: utf-8 -*-

module DataMapper
  module Validations
    module Fixtures
      class Company
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,       Serial
        property :title,    String
        property :type,     Discriminator


        #
        # Validations
        #

        validates_presence_of :title, :message => "Company name is a required field"

      end

      class ServiceCompany < Company

        #
        # Properties
        #

        without_auto_validations do
          property :area_of_expertise, String, :length => (1..60)
        end

        #
        # Validations
        #

        validates_presence_of :area_of_expertise
      end

      class ProductCompany < Company

        #
        # Properties
        #

        without_auto_validations do
          property :flagship_product, String, :length => (1..60)
        end

        #
        # Validations
        #

        validates_presence_of :title, :message => "Product company must have a name"
        validates_presence_of :flagship_product
      end

      class Product
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,   Serial
        property :name, String, :required => true

        #
        # Associations
        #

        belongs_to :company, :model => DataMapper::Validations::Fixtures::ProductCompany

        #
        # Validations
        #

        validates_presence_of :company
      end
    end
  end
end
