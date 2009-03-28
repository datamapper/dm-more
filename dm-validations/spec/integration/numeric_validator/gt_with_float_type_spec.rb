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


  describe "with three point line distance of 7.2" do
    before :all do
      @model.three_point_line_distance = 7.2
      @model.valid?
    end

    it_should_behave_like "valid model"
  end


  describe "with three point line distance of 3.5" do
    before :all do
      @model.three_point_line_distance = 3.5
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:three_point_line_distance).should include("Three point line distance must be a number greater than 6.7")
    end
  end
end
