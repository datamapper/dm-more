require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe DataMapper::Validate::Fixtures::Department do
    before :all do
      ::DataMapper::Validate::Fixtures::Department.create(:name => "HR")
    end

    describe "with unique name" do
      before :all do
        @model = ::DataMapper::Validate::Fixtures::Department.new(:name => "R & D")
      end

      it_should_behave_like "valid model"
    end

    describe "with a duplicate name" do
      before :all do
        @model = ::DataMapper::Validate::Fixtures::Department.new(:name => "HR")
      end

      it_should_behave_like "invalid model"
    end
  end



  describe DataMapper::Validate::Fixtures::Organisation do
    before :all do
       DataMapper.repository do
         @model = ::DataMapper::Validate::Fixtures::Organisation.create(:name => 'Apple', :domain => 'apple.com')
      end
    end

    describe "with missing domain" do
      before :all do
        @model.domain = nil
      end

      it_should_behave_like "valid model"
    end

    describe "with a duplicate domain" do
      before :all do
        @model.name   = "Fake Apple"
        @model.domain = "apple.com"
      end

      it_should_behave_like "invalid model"

      it "has a meaningful error message" do
        @model.valid?
        @model.errors.on(:domain).should include("Domain is already taken")
      end
    end
    
    it "shouldn't fail on itself when checking for records with identical fields" do
      @model.name = "Steve Job's Pony Express"
      @model.should be_valid
    end
  end



  describe DataMapper::Validate::Fixtures::User do
    before :all do
       DataMapper.repository do
         @organization_one = ::DataMapper::Validate::Fixtures::Organisation.create(:name => 'Org 101', :domain => '101')
         @organization_two = ::DataMapper::Validate::Fixtures::Organisation.create(:name => 'Org 102', :domain => '102')

         @dept             = ::DataMapper::Validate::Fixtures::Organisation.create(:name => 'accounting')

         ::DataMapper::Validate::Fixtures::User.create(:organisation => @organization_one, :user_name => 'guy', :department_id => @dept.id)
      end
    end

    describe "with username not valid across the organization" do
      before :all do
        @model = ::DataMapper::Validate::Fixtures::User.new(:organisation => @organization_one, :user_name => 'guy')
      end

      it "is not valid for signing up" do
        @model.should_not be_valid_for_signing_up_for_organization_account
      end

      it "has a meaningful error message" do
        @model.errors.on(:user_name).should include('User name is already taken')
      end
    end


    describe "with username not valid across the department" do
      before :all do
        @model = ::DataMapper::Validate::Fixtures::User.new(:department_id => @dept.id, :user_name => 'guy')
      end

      it "is not valid for setting up the account" do
        @model.should_not be_valid_for_signing_up_for_department_account
      end

      it "has a meaningful error message" do
        @model.errors.on(:user_name).should include('User name is already taken')
      end
    end
  end # describe DataMapper::Validate::Fixtures::User
end # if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
