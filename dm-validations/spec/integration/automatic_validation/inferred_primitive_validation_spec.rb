require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


describe SailBoat do
  before :all do
    @model = SailBoat.new(:id => 1)
    @model.should be_valid_for_primitive_test
  end

  describe "with invlid value assigned to primitive column" do
    before :all do
      @model.build_date = 'ABC'
    end

    it "is invalid" do
      @model.should_not be_valid_for_primitive_test
      @model.errors.on(:build_date).should include('Build date must be of type Date')
    end
  end
end
