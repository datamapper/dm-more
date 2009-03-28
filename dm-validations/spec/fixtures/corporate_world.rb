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
          property :department_id,   Integer
          property :user_name,       String

          belongs_to :organisation, :model => ::DataMapper::Validate::Fixtures::Organisation
          belongs_to :department,   :model => ::DataMapper::Validate::Fixtures::Department

          validates_is_unique :user_name, :when => :signing_up_for_department_account,   :scope => [:department_id]
          validates_is_unique :user_name, :when => :signing_up_for_organization_account, :scope => [:organisation]
        end

        Organisation.auto_migrate!
        User.auto_migrate!
      end
    end
  end
end
