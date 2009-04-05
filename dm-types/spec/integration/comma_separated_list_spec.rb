require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Fixtures::Person do
  before :all do
    @model = DataMapper::Types::Fixtures::Person.new(:name => "")
  end

  describe "with no interests information" do
    before :all do
      @model.interests = nil
    end

    describe "when dumped and loaded again" do
      before :all do
        @model.save.should be_true
        @model.reload
      end

      it "has nil interests list" do
        @model.interests.should be_nil
      end
    end
  end


  describe "with a few items on the interests list" do
    before :all do
      @input = 'fire, water, fire, a whole lot of other interesting things, ,,,'
      @model.interests = @input
    end

    describe "when dumped and loaded again" do
      before :all do
        @model.save.should be_true
        @model.reload
      end

      it "includes 'fire' in interests" do
        @model.interests.should include("fire")
      end

      it "includes 'water' in interests" do
        @model.interests.should include("water")
      end

      it "includes 'a whole lot of other interesting things' in interests" do
        @model.interests.should include("a whole lot of other interesting things")
      end

      it "has blank entries removed" do
        @model.interests.any? { |i| i.blank? }.should be_false
      end

      it "has duplicates removed" do
        @model.interests.select { |i| i == 'fire' }.size.should == 1
      end
    end
  end


  describe "with interests information given as empty list" do
    it "raises ArgumentError" do
      lambda do
        @model.interests = []
        @model.save
      end.should raise_error(ArgumentError, /must be nil or a String/)
    end
  end
end
