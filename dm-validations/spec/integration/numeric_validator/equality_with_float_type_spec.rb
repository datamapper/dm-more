require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


describe DataMapper::Validate::Fixtures::BasketballCourt do
  describe "with valid set of attributes" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BasketballCourt.valid_instance
      @model.valid?
    end

    it_should_behave_like "valid model"
  end


  describe "with rim height of 3.05" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BasketballCourt.valid_instance(:rim_height => 3.05)
      @model.valid?
    end

    it_should_behave_like "valid model"
  end


  describe "with rim height of 3.30" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BasketballCourt.valid_instance(:rim_height => 3.30)
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:rim_height).should include("Rim height must be a number equal to 3.05")
    end
  end


  describe "with free throw line distance of 4.57" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BasketballCourt.valid_instance(:free_throw_line_distance => 4.57)
      @model.valid?
    end

    it_should_behave_like "valid model"
  end


  describe "with free throw line distance of 3.10" do
    before :all do
      @model = DataMapper::Validate::Fixtures::BasketballCourt.valid_instance(:free_throw_line_distance => 3.10)
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:free_throw_line_distance).should include("Free throw line distance must be a number equal to 4.57")
    end
  end
end
