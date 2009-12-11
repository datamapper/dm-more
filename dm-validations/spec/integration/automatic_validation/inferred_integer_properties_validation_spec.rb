require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe "A model with an Integer property" do
  before :all do
    SailBoat.auto_migrate!

    @model = SailBoat.new
  end

  describe "assigned to an integer" do
    before :all do
      @model.set(:id => 1)
    end

    it_should_behave_like "valid model"
  end

  describe "assigned to a float" do
    before :all do
      @model.set(:id => 1.0)
    end

    it "is invalid" do
      @model.should_not be_valid
    end

    it "has a meaningful default error message" do
      @model.errors.on(:id).should == [ 'Id must be an integer' ]
    end
  end

  describe "assigned to a BigDecimal" do
    before :all do
      @model.set(:id => BigDecimal('1'))
    end

    it "is invalid" do
      @model.should_not be_valid
    end

    it "has a meaningful default error message" do
      @model.errors.on(:id).should == [ 'Id must be an integer' ]
    end
  end

  describe "assigned to a too-small integer" do
    before :all do
      @model.set(:id => 0)
    end

    it "is invalid" do
      @model.should_not be_valid
    end

    it "has a meaningful default error message" do
      @model.errors.on(:id).should == [ 'Id must be greater than or equal to 1' ]
    end
  end

  describe "assigned to a too-large integer" do
    before :all do
      @model.set(:id => 11)
    end

    it "is invalid" do
      @model.should_not be_valid
    end

    it "has a meaningful default error message" do
      @model.errors.on(:id).should == [ 'Id must be less than or equal to 10' ]
    end
  end

end
