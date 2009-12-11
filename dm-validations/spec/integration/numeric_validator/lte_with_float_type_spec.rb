require 'spec_helper'
require 'integration/numeric_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::BasketballCourt' do
  before :all do
    DataMapper::Validate::Fixtures::BasketballCourt.auto_migrate!

    @model = DataMapper::Validate::Fixtures::BasketballCourt.valid_instance
    @model.valid?
  end

  it_should_behave_like "valid model"


  describe "with length of 15.24" do
    before :all do
      @model.length = 15.24
      @model.valid?
    end

    it_should_behave_like "valid model"
  end


  describe "with length of 20.0" do
    before :all do
      @model.length = 20.0
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:length).should == [ 'Length must be less than or equal to 15.24' ]
    end
  end
end
