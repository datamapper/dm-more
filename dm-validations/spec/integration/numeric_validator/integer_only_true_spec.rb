require 'spec_helper'
require 'integration/numeric_validator/spec_helper'

describe 'Country' do
  before do
    Country.auto_migrate!

    @country = Country.new(:name => "Italy", :area => "301318")
  end

  describe "with area as integer" do
    before do
      # no op in this case
    end

    it "is valid" do
      @country.should be_valid
    end
  end


  describe "with area as integer" do
    before do
      @country.area = 1603
    end

    it "is valid" do
      @country.should be_valid
    end
  end


  describe "with area as string containing only integers" do
    before do
      @country.area = "301318"
    end

    it "is valid" do
      @country.should be_valid
    end
  end


  describe "with area as string containing a float" do
    before do
      @country.area = "301318.6"
    end

    it "IS valid" do
      @country.should be_valid
    end
  end


  describe "with area as string containing random alphanumeric characters" do
    before do
      @country.area = "area=51"
    end

    it "IS NOT valid" do
      @country.should_not be_valid
    end
  end


  describe "with area as string containing random punctuation characters" do
    before do
      @country.area = "$$ * $?"
    end

    it "IS NOT valid" do
      @country.should_not be_valid
    end
  end


  describe "with unknown area" do
    before do
      @country.area = nil
    end

    it "is NOT valid" do
      @country.should_not be_valid
    end

    it "has a meaningful error message on for the property" do
      @country.valid?
      @country.errors.on(:area).should == [ 'Please use integers to specify area' ]
    end
  end
end
