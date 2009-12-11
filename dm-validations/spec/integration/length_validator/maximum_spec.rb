require 'spec_helper'
require 'integration/length_validator/spec_helper'

describe "barcode with invalid code length", :shared => true do
  it "has a meaninful error message with length restrictions mentioned" do
    @model.errors.on(:code).should == [ 'Code must be at most 10 characters long' ]
  end
end

describe 'DataMapper::Validate::Fixtures::Barcode' do
  before :all do
    DataMapper::Validate::Fixtures::Barcode.auto_migrate!

    @model = DataMapper::Validate::Fixtures::Barcode.valid_instance
  end

  it_should_behave_like "valid model"

  describe "with a 17 characters long code" do
    before :all do
      @model.code = "18283849284728124"
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it_should_behave_like "barcode with invalid code length"
  end

  describe "with a 7 characters long code" do
    before :all do
      @model.code = "8372786"
      @model.valid?
    end

    it_should_behave_like "valid model"
  end

  describe "with an 11 characters long code" do
    before :all do
      @model.code = "83727868754"
      @model.valid?
    end

    it_should_behave_like "invalid model"

    it_should_behave_like "barcode with invalid code length"
  end
end
