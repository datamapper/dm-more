# -*- coding: utf-8 -*-

module DataMapper
  module Validations
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
        validates_format_of :doc_no, :with => lambda { |code|
          code =~ /\AA\d{4}\z/ || code =~ /\A[B-Z]\d{6}X12\z/
        }

        validates_format_of :email, :as => :email_address
        validates_format_of :url, :as => :url, :allow_nil => false, :allow_blank => false

        validates_format_of :username, :with => /[a-z]/, :message => 'Username must have at least one letter', :allow_nil => true
        validates_format_of :code,     :with => /\d{5,6}/, :message => 'Code format is invalid'
      end
    end # Fixtures
  end # Validations
end # DataMapper
