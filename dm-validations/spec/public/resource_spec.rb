require 'spec_helper'

describe 'DataMapper::Resource' do
  before :all do
    DataMapper::Validations::Fixtures::Barcode.auto_migrate!

    @resource = DataMapper::Validations::Fixtures::Barcode.new
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
        DataMapper::Validations::Fixtures::Organisation.auto_migrate!
        DataMapper::Validations::Fixtures::Department.auto_migrate!
        DataMapper::Validations::Fixtures::User.auto_migrate!

        organization = DataMapper::Validations::Fixtures::Organisation.create(:name => 'Org 101', :domain => '101')
        dept         = DataMapper::Validations::Fixtures::Department.create(:name => 'accounting')

        attributes = {
          :organisation => organization,
          :user_name    => 'guy',
          :department   => dept,
        }

        # create a record that will be a dupe when User#update is executed below
        DataMapper::Validations::Fixtures::User.create(attributes).should be_saved

        @resource = DataMapper::Validations::Fixtures::User.create(attributes.merge(:user_name => 'other'))

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

  describe '#save' do
    before :all do
      @resource.code = 'a' * 10
      @resource.save
    end

    describe 'on a new resource' do
      it 'should call valid? once' do
        @resource.valid_hook_call_count.should == 1
      end
    end

    describe 'on a saved, non-dirty resource' do
      before :all do
        # reload the resource
        @resource = @resource.model.get(*@resource.key)
        @resource.save
      end

      it 'should not call valid?' do
        @resource.valid_hook_call_count.should be_nil
      end
    end

    describe 'on a saved, dirty resource' do
      before :all do
        # reload the resource
        @resource = @resource.model.get(*@resource.key)
        @resource.code = 'b' * 10
        @resource.save
      end

      it 'should call valid? once' do
        @resource.valid_hook_call_count.should == 1
      end
    end
  end
end
