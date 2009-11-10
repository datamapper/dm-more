# -*- coding: utf-8 -*-

module DataMapper
  module Validate
    module Fixtures
      class BillOfLading
        #
        # Behaviors
        #

        include DataMapper::Resource

        #
        # Properties
        #

        property :id,       Serial

        property :doc_no,   String, :auto_validation => false
        property :email,    String, :auto_validation => false
        property :username, String, :auto_validation => false
        property :url,      String, :auto_validation => false
        property :code,     String, :auto_validation => false, :default => "123456"

        #
        # Validations
        #

        # this is a trivial example
        validates_format :doc_no, :with => lambda { |code|
          code =~ /\AA\d{4}\z/ || code =~ /\A[B-Z]\d{6}X12\z/
        }

        validates_format :email, :as => :email_address
        validates_format :url, :as => :url, :allow_nil => false, :allow_blank => false

        validates_format :username, :with => /[a-z]/, :message => 'Username must have at least one letter', :allow_nil => true
        validates_format :code,     :with => /\d{5,6}/, :message => 'Code format is invalid'
      end
    end # Fixtures
  end # Validate
end # DataMapper
