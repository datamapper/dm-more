require 'spec_helper'
require 'integration/automatic_validation/spec_helper'

describe 'SailBoat', "with a :format option on a property" do
  before :all do
    SailBoat.auto_migrate!

    @model = SailBoat.new
    @model.should be_valid_for_format_test
  end

  describe "and value that matches the format" do
    before :all do
      @model.code = 'A1234'
    end

    it "passes inferred format validation" do
      @model.should be_valid_for_format_test
    end
  end

  describe "and value that DOES NOT match the format" do
    before :all do
      @model.code = 'BAD CODE'
    end

    it "does not pass inferred format validation" do
      @model.should_not be_valid_for_format_test
    end

    it "has a meaningful error message" do
      @model.errors.on(:code).should == [ 'Code has an invalid format' ]
    end
  end
end
