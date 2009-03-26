require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

# global first, then local to length validators
require __dir__.parent.parent + "spec_helper"
require __dir__ + 'spec_helper'

describe DataMapper::Validate::Fixtures::Jabberwock do
  before :all do
    @model = DataMapper::Validate::Fixtures::Jabberwock.new
  end

  describe "without snickersnack" do
    before :all do
      @model.snickersnack = nil
    end

    it_should_behave_like "invalid model"

    it "has custom error message" do
      @model.errors.on(:snickersnack).should include("worble warble")
    end
  end
end
