require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe "A model with a Boolean property" do
  before :all do
    @model = HasNullableBoolean.new(:id => 1)
  end

  describe "assigned to true" do
    before :all do
      @model.set(:bool => true)
    end

    it_should_behave_like "valid model"
  end

  describe "assigned to false" do
    before :all do
      @model.set(:bool => false)
    end

    it_should_behave_like "valid model"
  end

  describe "assigned to a nil" do
    before :all do
      @model.set(:bool => nil)
    end

    it_should_behave_like "valid model"
  end
end



describe "A model with a required Boolean property" do
  before :all do
    @model = HasNotNullableBoolean.new(:id => 1)
  end

  describe "assigned to true" do
    before :all do
      @model.set(:bool => true)
    end

    it_should_behave_like "valid model"
  end

  describe "assigned to false" do
    before :all do
      @model.set(:bool => false)
    end

    it_should_behave_like "valid model"
  end

  describe "assigned to a nil" do
    before :all do
      @model.set(:bool => nil)
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:bool).should == [ 'Bool must not be nil' ]
    end
  end
end



describe "A model with a required paranoid Boolean property" do
  before :all do
    @model = HasNotNullableParanoidBoolean.new(:id => 1)
  end

  describe "assigned to true" do
    before :all do
      @model.set(:bool => true)
    end

    it_should_behave_like "valid model"
  end

  describe "assigned to false" do
    before :all do
      @model.set(:bool => false)
    end

    it_should_behave_like "valid model"
  end

  describe "assigned to a nil" do
    before :all do
      @model.set(:bool => nil)
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:bool).should == [ 'Bool must not be nil' ]
    end
  end
end
