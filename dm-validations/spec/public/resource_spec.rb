require 'spec_helper'

describe 'DataMapper::Resource' do
  before :all do
    DataMapper::Validate::Fixtures::Barcode.auto_migrate!

    @resource = DataMapper::Validate::Fixtures::Barcode.new
  end

  describe '#update' do
    describe 'when provided valid attributes' do
      before :all do
        @response = @resource.update(:code => 'a' * 10)
      end

      it 'should return true' do
        @response.should be_true
      end
    end

    describe 'when provided invalid attributes' do
      before :all do
        @response = @resource.update(:code => 'a' * 11)
      end

      it 'should return false' do
        @response.should be_false
      end

      it 'should set errors' do
        @resource.errors.to_a.should == [ [ 'Code must be at most 10 characters long' ] ]
      end
    end

    describe 'when provided invalid attributes and a context' do
      before :all do
        DataMapper::Validate::Fixtures::Organisation.auto_migrate!
        DataMapper::Validate::Fixtures::Department.auto_migrate!
        DataMapper::Validate::Fixtures::User.auto_migrate!

        organization = DataMapper::Validate::Fixtures::Organisation.create(:name => 'Org 101', :domain => '101')
        dept         = DataMapper::Validate::Fixtures::Department.create(:name => 'accounting')

        attributes = {
          :organisation => organization,
          :user_name    => 'guy',
          :department   => dept,
        }

        # create a record that will be a dupe when User#update is executed below
        DataMapper::Validate::Fixtures::User.create(attributes).should be_saved

        @resource = DataMapper::Validate::Fixtures::User.create(attributes.merge(:user_name => 'other'))

        @response = @resource.update(attributes, :signing_up_for_department_account)
      end

      it 'should return false' do
        @response.should be_false
      end

      it 'should set errors' do
        @resource.errors.to_a.should == [ [ 'User name is already taken' ] ]
      end
    end
  end
end
