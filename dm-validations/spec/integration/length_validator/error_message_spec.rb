require 'spec_helper'
require 'integration/length_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::Jabberwock' do
  before :all do
    DataMapper::Validate::Fixtures::Jabberwock.auto_migrate!

    @model = DataMapper::Validate::Fixtures::Jabberwock.new
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
