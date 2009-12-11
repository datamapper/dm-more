require 'spec_helper'
require 'integration/primitive_validator/spec_helper'

describe 'DataMapper::Validate::Fixtures::MemoryObject' do
  include DataMapper::Validate::Fixtures

  before :all do
    DataMapper::Validate::Fixtures::MemoryObject.auto_migrate!

    @model = DataMapper::Validate::Fixtures::MemoryObject.new
  end

  describe "with color given as a string" do
    before :all do
      @model.color = "grey"
    end

    it "is valid" do
      @model.should be_valid
    end
  end


  describe "with color given as an object" do
    before :all do
      # we have to go through the back door
      # since writer= method does typecasting
      # and Object is casted to String
      @model.instance_variable_set(:@color,  Object.new)
    end

    it "is NOT valid" do
      @model.should_not be_valid
    end
  end


  describe "with mark flag set to true" do
    before :all do
      @model.marked = true
    end

    it "is valid" do
      @model.should be_valid
    end
  end


  describe "with mark flag set to false" do
    before :all do
      @model.marked = false
    end

    it "is valid" do
      @model.should be_valid
    end
  end

  describe "with mark flag set to an object" do
    before :all do
      # go through the back door to avoid typecasting
      @model.instance_variable_set(:@marked, Object.new)
    end

    it "is NOT valid" do
      @model.should_not be_valid
    end
  end


  describe "with color set to nil" do
    before :all do
      # go through the back door to avoid typecasting
      @model.color = nil
    end

    it "is valid" do
      @model.should be_valid
    end
  end


  describe "with mark flag set to nil" do
    before :all do
      @model.marked = nil
    end

    it "is valid" do
      @model.should be_valid
    end
  end
end
