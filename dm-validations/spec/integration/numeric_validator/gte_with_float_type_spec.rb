require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


describe DataMapper::Validate::Fixtures::BasketballCourt do
  before :all do
    @model = DataMapper::Validate::Fixtures::BasketballCourt.valid_instance
    @model.valid?
  end

  it_should_behave_like "valid model"


  describe "with length of 15.0" do
    before :all do
      @model.length = 15.0
      @model.valid?
    end

    it_should_behave_like "valid model"
  end


  describe "with length of 14.0" do
    before :all do
      @model.length = 14.0
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:length).should include("Length must be a number greater than or equal to 15.0")
    end
  end
end
