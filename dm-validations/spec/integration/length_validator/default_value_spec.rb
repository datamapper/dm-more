require 'spec_helper'
require 'integration/length_validator/spec_helper'

describe 'DataMapper::Validations::Fixtures::BoatDock' do
  before :all do
    DataMapper::Validations::Fixtures::BoatDock.auto_migrate!

    @model = DataMapper::Validations::Fixtures::BoatDock.new
  end

  describe "with default values that are valid" do
    it_should_behave_like "valid model"
  end
end
