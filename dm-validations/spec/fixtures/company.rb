# -*- coding: utf-8 -*-

module DataMapper
  module Validate
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

        validates_present :title, :message => "Company name is a required field"

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

        validates_present :area_of_expertise
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

        validates_present :title, :message => "Product company must have a name"
        validates_present :flagship_product
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

        belongs_to :company, :model => DataMapper::Validate::Fixtures::ProductCompany

        #
        # Validations
        #

        validates_present :company
      end
    end
  end
end
