# -*- coding: utf-8 -*-

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  module DataMapper
    module Validate
      module Fixtures
        class Organisation
          include DataMapper::Resource
          property :id, Serial

          property :name, String
          property :domain, String #, :unique => true

          validates_is_unique :domain, :allow_nil => true
        end

        class Department
          include DataMapper::Resource

          property :id, Serial
          property :name, String

          validates_is_unique :name
          auto_migrate!
        end

        class User
          include DataMapper::Resource

          property :id, Serial

          property :organisation_id, Integer
          property :user_name, String

          belongs_to :organisation, :class_name => "::DataMapper::Validate::Fixtures::Organisation"

          validates_is_unique :user_name, :when => :testing_association, :scope => [:organisation]
          validates_is_unique :user_name, :when => :testing_property, :scope => [:organisation_id]
        end

        Organisation.auto_migrate!
        User.auto_migrate!
      end
    end
  end
end