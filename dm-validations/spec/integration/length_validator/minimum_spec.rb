require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

# global first, then local to length validators
require __dir__.parent.parent + "spec_helper"
require __dir__ + 'spec_helper'

require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

# global first, then local to length validators
require __dir__.parent.parent + "spec_helper"
require __dir__ + 'spec_helper'

describe ::DataMapper::Validate::Fixtures::MotorLaunch, "with name length required to be 5 chars minimum" do
  before :all do
    class ::DataMapper::Validate::Fixtures::MotorLaunch
      validators.clear!
      validates_length :name, :min => 5, :message => Proc.new { "Name must be longer than 5 characters long" }
    end

    @model = DataMapper::Validate::Fixtures::MotorLaunch.new
  end

  describe "and name that is longer than 5 characters" do
    before :all do
      @model.name = "DataMapper"
    end

    it_should_behave_like "valid model"
  end

  describe "and name that is shorter than 5 characters" do
    before :all do
      @model.name = "Ruby"
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message on invalid property" do
      @model.errors.on(:name).should include("Name must be longer than 5 characters long")
    end
  end
end
