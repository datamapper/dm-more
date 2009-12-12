require 'spec_helper'

try_spec do

  require './spec/fixtures/person'

  describe DataMapper::Types::Fixtures::Person do
    before :all  do
      @resource  = DataMapper::Types::Fixtures::Person.create(:password => 'DataMapper R0cks!')
      DataMapper::Types::Fixtures::Person.create(:password => 'password1')

      @people = DataMapper::Types::Fixtures::Person.all
      @resource.reload
    end

    it 'persists the password on initial save' do
      @resource.password.should       == 'DataMapper R0cks!'
      @people.last.password.should == 'password1'
    end

    it 'recalculates password hash on attribute update' do
      @resource.attribute_set(:password, 'bcryptic obscure')
      @resource.save

      @resource.reload
      @resource.password.should     == 'bcryptic obscure'
      @resource.password.should_not == 'DataMapper R0cks!'
    end

    it 'does not change password value on reload' do
      resource = @people.last
      original = resource.password.to_s
      resource.reload
      resource.password.to_s.should == original
    end

    it 'uses cost of BCrypt::Engine::DEFAULT_COST' do
      @resource.password.cost.should == BCrypt::Engine::DEFAULT_COST
    end
  end
end
