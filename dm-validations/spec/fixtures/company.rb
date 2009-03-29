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

        # rely on inferred validations here
        property :area_of_expertise, String, :length => (1..60), :nullable => false

      end


      class ProductCompany < Company

        #
        # Properties
        #

        # DO NOT rely on inferred validations here
        without_auto_validations do
          property :flagship_product, String, :length => (1..60)
        end

        #
        # Validations
        #

        validates_present :title, :message => "Product company must have a name"
        validates_present :flagship_product
      end
    end
  end
end
