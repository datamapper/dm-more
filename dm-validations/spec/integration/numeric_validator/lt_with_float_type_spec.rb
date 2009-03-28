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


  describe "with three point line distance of 6.8" do
    before :all do
      @model.three_point_line_distance = 6.8
      @model.valid?
    end

    it_should_behave_like "valid model"
  end


  describe "with three point line distance of 10.0" do
    before :all do
      @model.three_point_line_distance = 10.0
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:three_point_line_distance).should include("Three point line distance must be a number less than 7.24")
    end
  end
end
