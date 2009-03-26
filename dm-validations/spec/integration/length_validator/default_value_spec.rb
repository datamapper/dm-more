require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path

# global first, then local to length validators
require __dir__.parent.parent + "spec_helper"
require __dir__ + 'spec_helper'

describe ::DataMapper::Validate::Fixtures::BoatDock do
  before :all do
    @model = ::DataMapper::Validate::Fixtures::BoatDock.new
  end

  describe "with default values that are valid" do
    it_should_behave_like "valid model"
  end
end
