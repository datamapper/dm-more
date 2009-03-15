require 'pathname'
__dir__ = Pathname(__FILE__).dirname.expand_path
require __dir__.parent.parent + 'spec_helper'
require __dir__ + 'spec_helper'

describe DataMapper::Validate::Fixtures::G3Concert do
  before :all do
    @model = DataMapper::Validate::Fixtures::G3Concert.new(:year => 2004, :participants => "Joe Satriani, Steve Vai, Yngwie Malmsteen", :city => "Denver")
    @model.should be_valid
  end

  describe "some non existing year/participants/city combination" do
    before :all do
      @model.year = 2015
    end

    it_should_behave_like "invalid model"

    it "uses error messages returned by the validation block" do
      @model.errors.on(:participants).should include("this G3 is probably yet to take place")
    end
  end


  describe "existing year/participants/city combination" do
    before :all do
      @model.year         = 2001
      @model.city         = "Los Angeles"
      @model.participants = "Joe Satriani, Steve Vai, John Petrucci"
    end

    it_should_behave_like "valid model"
  end
end
