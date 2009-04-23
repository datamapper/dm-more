require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

describe "A model with an Integer property" do
  before :all do
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
      @model.errors.on(:id).should include('Id must be an integer')
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
      @model.errors.on(:id).should include('Id must be an integer')
    end
  end
end
