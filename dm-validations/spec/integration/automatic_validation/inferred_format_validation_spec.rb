require 'pathname'

__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

describe SailBoat, "with a :format option on a property" do
  before :all do
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
      @model.errors.on(:code).should include('Code has an invalid format')
    end
  end
end
