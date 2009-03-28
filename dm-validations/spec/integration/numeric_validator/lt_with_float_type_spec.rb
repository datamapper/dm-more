require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'


describe DataMapper::Validate::Fixtures::Mittelschnauzer do
  before :all do
    @model = DataMapper::Validate::Fixtures::Mittelschnauzer.valid_instance
  end

  it_should_behave_like "valid model"

  describe "with height of 56.1 (higher than allowed maximum)" do
    before :all do
      @model.height = 56.1
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:height).should include("Height must be a number less than 55.2")
    end
  end
end
