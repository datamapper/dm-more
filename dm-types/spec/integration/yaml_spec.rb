require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Fixtures::Person do
  before :all do
    @model = DataMapper::Types::Fixtures::Person.new(:name => "")
  end

  describe "with no inventions information" do
    before :all do
      @model.inventions = nil
    end

    describe "when dumped and loaded again" do
      before :all do
        @model.save.should be_true
        @model.reload
      end

      it "has nil inventions list" do
        @model.inventions.should be_nil
      end
    end
  end


  describe "with a few items on the inventions list" do
    before :all do
      @input = ['carbon telephone transmitter', 'light bulb', 'electric grid'].map do |name|
        DataMapper::Types::Fixtures::Invention.new(name)
      end
      @model.inventions = @input
    end

    describe "when dumped and loaded again" do
      before :all do
        @model.save.should be_true
        @model.reload
      end

      it "loads inventions list to the state when it was dumped/persisted with keys being strings" do
        @model.inventions.should == @input
      end
    end
  end


  describe "with inventions information given as empty list" do
    before :all do
      @model.inventions = []
    end

    describe "when dumped and loaded again" do
      before :all do
        @model.save.should be_true
        @model.reload
      end

      it "has empty inventions list" do
        @model.inventions.should == []
      end
    end
  end
end
