require 'spec_helper'
require 'integration/length_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::BoatDock' do
  before :all do
    DataMapper::Validate::Fixtures::BoatDock.auto_migrate!

    @model = DataMapper::Validate::Fixtures::BoatDock.new
  end

  describe "with default values that are valid" do
    it_should_behave_like "valid model"
  end
end
