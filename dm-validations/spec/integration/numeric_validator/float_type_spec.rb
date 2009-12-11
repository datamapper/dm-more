require 'spec_helper'
require 'integration/numeric_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::BasketballPlayer' do
  before :all  do
    DataMapper::Validate::Fixtures::BasketballPlayer.auto_migrate!

    @model = DataMapper::Validate::Fixtures::BasketballPlayer.new(:name => "Michael Jordan", :height => 198.1, :weight => 97.2)
  end

  describe "with height as float" do
    before :all  do
      # no op in this case
    end

    it_should_behave_like "valid model"
  end

  describe "with height as integer" do
    before :all  do
      @model.height = 198
    end

    it_should_behave_like "valid model"
  end

  describe "with height as string containing only integers" do
    before :all  do
      @model.height = "198"
    end

    it_should_behave_like "valid model"
  end

  describe "with height as string containing a float" do
    before :all do
      @model.height = "198.1"
    end

    it_should_behave_like "valid model"
  end

  describe "with height as string containing a float that will be represented in scientific notation" do
    before :all do
      @model.height = '0.00004'
    end

    it_should_behave_like "valid model"
  end

  describe "with height as string containing random alphanumeric characters" do
    before :all do
      @height = 'height=198.1'
      @model.height = "height=198.1"
    end

    it "is should not change the value" do
      @model.height.should == @height
    end

    it_should_behave_like "invalid model"
  end

  describe "with height as string containing random punctuation characters" do
    before :all do
      @height = '$$ * $?'
      @model.height = @height
    end

    it "is should not change the value" do
      @model.height.should == @height
    end

    it_should_behave_like "invalid model"
  end

  describe "with nil height" do
    before :all do
      @model.height = nil
      @model.valid?
    end

    # typecasting kicks in
    it_should_behave_like "invalid model"

    it "has a meaningful error message" do
      @model.errors.on(:height).should == [ 'Height must be a number' ]
    end
  end
end
