require 'spec_helper'
require 'integration/numeric_validator/spec_helper'

describe 'City' do
  before do
    City.auto_migrate!

    @city = City.new(:name => "Tokyo", :founded_in => 1603)
  end

  describe "with foundation year as integer" do
    before do
      # no op in this case
    end

    it "is valid" do
      @city.should be_valid
    end
  end


  describe "with foundation year as integer" do
    before do
      @city.founded_in = 1603
    end

    it "is valid" do
      @city.should be_valid
    end
  end


  describe "with foundation year as string containing only integers" do
    before do
      @city.founded_in = "1603"
    end

    it "is valid" do
      @city.should be_valid
    end
  end


  describe "with foundation year as string containing a float" do
    before do
      @city.founded_in = "1603.6"
    end

    it "is valid" do
      @city.should be_valid
    end
  end


  describe "with foundation year as string that is not an integer or float" do
    before do
      @string = "founded-in=1603"

      @city.founded_in = @string
    end

    it "is not altered" do
      @city.founded_in.should be(@string)
    end

    it "IS NOT valid" do
      @city.should_not be_valid
    end
  end


  describe "with unknown foundation date" do
    before do
      @city.founded_in = nil
    end

    it "is NOT valid" do
      @city.should_not be_valid
    end

    it "has a meaningful error message on for the property" do
      @city.valid?
      @city.errors.on(:founded_in).should == [ 'Foundation year must be an integer' ]
    end
  end
end
