# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class Company
        #
        # Behaviors
        #
        
        include DataMapper::Resource

        property :id,       Serial
        property :title,    String
        property :type,     Discriminator


        #
        # Validations
        #
        
        validates_present :title, :message => "Company name is a required field"

      end

      class ServiceCompany < Company
      end

      class ProductCompany < Company
      end
    end
  end
end
