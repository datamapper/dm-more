# -*- coding: utf-8 -*-

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  module DataMapper
    module Validate
      module Fixtures
        class Organisation
          include DataMapper::Resource

          property :id, Serial
          property :name, String
          property :domain, String, :unique_index => true

          validates_is_unique :domain, :allow_nil => true
        end

        class Department
          include DataMapper::Resource

          property :id, Serial
          property :name, String, :unique_index => true

          validates_is_unique :name
        end

        class User
          include DataMapper::Resource

          property :id, Serial
          property :user_name, String

          belongs_to :organisation
          belongs_to :department

          validates_is_unique :user_name, :when => :signing_up_for_department_account,   :scope => [:department]
          validates_is_unique :user_name, :when => :signing_up_for_organization_account, :scope => [:organisation]
        end
      end
    end
  end
end
