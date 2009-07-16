require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

unless defined?(::BCrypt)
  skip_tests = true
  puts '[WARNING] Skipping BcryptHash tests, please do gem install bcrypt-ruby'
end

describe DataMapper::Types::Fixtures::Person do
  unless skip_tests
    before :all  do
      @model  = DataMapper::Types::Fixtures::Person.create(:password => "DataMapper R0cks!")
      DataMapper::Types::Fixtures::Person.create(:password => "password1")

      @people = DataMapper::Types::Fixtures::Person.all
      @model.reload
    end

    it "persists the password on initial save" do
      @model.password.should       == "DataMapper R0cks!"
      @people.last.password.should == "password1"
    end

    it "recalculates password hash on attribute update" do
      @model.attribute_set(:password, "bcryptic obscure")
      @model.save

      @model.reload
      @model.password.should     == 'bcryptic obscure'
      @model.password.should_not == 'DataMapper R0cks!'
    end

    it "does not change password value on reload" do
      model    = @people.last
      original = model.password.to_s
      model.reload
      model.password.to_s.should == original
    end

    it "uses cost of BCrypt::Engine::DEFAULT_COST" do
      @model.password.cost.should == BCrypt::Engine::DEFAULT_COST
    end
  end
end
