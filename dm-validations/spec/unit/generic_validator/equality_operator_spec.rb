require 'spec_helper'

describe 'DataMapper::Validations::GenericValidator' do
  describe "when types and fields are equal" do
    it "returns true" do
      DataMapper::Validations::PresenceValidator.new(:name).
        should == DataMapper::Validations::PresenceValidator.new(:name)
    end
  end


  describe "when types differ" do
    it "returns false" do
      DataMapper::Validations::PresenceValidator.new(:name).
        should_not == DataMapper::Validations::UniquenessValidator.new(:name)
    end
  end


  describe "when property names differ" do
    it "returns false" do
      DataMapper::Validations::PresenceValidator.new(:first_name).
        should_not == DataMapper::Validations::PresenceValidator.new(:last_name)
    end
  end
end
