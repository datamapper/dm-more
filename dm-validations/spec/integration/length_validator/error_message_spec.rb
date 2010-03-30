require 'spec_helper'
require 'integration/length_validator/spec_helper'

describe 'DataMapper::Validations::Fixtures::Jabberwock' do
  before :all do
    DataMapper::Validations::Fixtures::Jabberwock.auto_migrate!

    @model = DataMapper::Validations::Fixtures::Jabberwock.new
  end

  describe "without snickersnack" do
    before :all do
      @model.snickersnack = nil
    end

    it_should_behave_like "invalid model"

    it "has custom error message" do
      @model.errors.on(:snickersnack).should == [ 'worble warble' ]
    end
  end
end
