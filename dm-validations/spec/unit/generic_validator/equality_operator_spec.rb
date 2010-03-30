require 'spec_helper'

describe 'DataMapper::Validate::GenericValidator' do
  describe "when types and fields are equal" do
    it "returns true" do
      DataMapper::Validate::PresenceValidator.new(:name).
        should == DataMapper::Validate::PresenceValidator.new(:name)
    end
  end


  describe "when types differ" do
    it "returns false" do
      DataMapper::Validate::PresenceValidator.new(:name).
        should_not == DataMapper::Validate::UniquenessValidator.new(:name)
    end
  end


  describe "when property names differ" do
    it "returns false" do
      DataMapper::Validate::PresenceValidator.new(:first_name).
        should_not == DataMapper::Validate::PresenceValidator.new(:last_name)
    end
  end
end
