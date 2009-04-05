require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Fixtures::Person do
  before :all do
    @model = DataMapper::Types::Fixtures::Person.new(:name => "Thomas Edison")
  end

  describe "with no positions information" do
    before :all do
      @model.positions = nil
    end

    describe "when dumped and loaded again" do
      before :all do
        @model.save.should be_true
        @model.reload
      end

      it "has nil positions list" do
        @model.positions.should be_nil
      end
    end
  end


  describe "with a few items on the positions list" do
    before :all do
      @model.positions = [
                         { :company => "The Death Star, Inc", :title => "Light sabre engineer" },
                         { :company => "Sane Little Company", :title => "Chief Curiosity Officer" }
                        ]
    end

    describe "when dumped and loaded again" do
      before :all do
        @model.save.should be_true
        @model.reload
      end

      it "loads positions list to the state when it was dumped/persisted with keys being strings" do
        @model.positions.should == [
                                    { "company" => "The Death Star, Inc",  "title" => "Light sabre engineer"    },
                                    { "company"  => "Sane Little Company", "title" => "Chief Curiosity Officer" }
                                   ]
      end
    end
  end


  describe "with positions information given as empty list" do
    before :all do
      @model.positions = []
    end

    describe "when dumped and loaded again" do
      before :all do
        @model.save.should be_true
        @model.reload
      end

      it "has empty positions list" do
        @model.positions.should == []
      end
    end
  end
end
