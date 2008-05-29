require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'


describe DataMapper::Serialize do
  before(:all) do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

    @collection = DataMapper::Collection.new(query)
    @collection.load([1, 2, 'Betsy', 'Jersey'])
    @collection.load([10, 20, 'Berta', 'Guernsey'])

    @empty_collection = DataMapper::Collection.new(query)
  end

  #
  # ==== ajaxy JSON
  #

  describe "#to_json" do
    it "serializes resource to JSON" do
      deserialized_hash = JSON.parse(Cow.new(:id => 1, :composite => 322, :name => "Harry", :breed => "Angus").to_json)

      deserialized_hash["id"].should        == 1
      deserialized_hash["composite"].should == 322
      deserialized_hash["name"].should      == "Harry"
      deserialized_hash["breed"].should     == "Angus"
    end

    it "excludes nil attributes" do
      deserialized_hash = JSON.parse(Cow.new(:id => 1, :name => "Harry", :breed => "Angus").to_json)

      deserialized_hash["id"].should        == 1
      deserialized_hash["composite"].should be(nil)
      deserialized_hash["name"].should      == "Harry"
      deserialized_hash["breed"].should     == "Angus"
    end

    it "serializes collections to JSON by serializing each member" do
      deserialized_collection = JSON.parse(@collection.to_json)
      betsy = deserialized_collection.first
      berta = deserialized_collection.last

      betsy["id"].should        == 1
      betsy["composite"].should == 2
      betsy["name"].should      == "Betsy"
      betsy["breed"].should     == "Jersey"

      berta["id"].should        == 10
      berta["composite"].should == 20
      berta["name"].should      == "Berta"
      berta["breed"].should     == "Guernsey"
    end

    it "handles empty collections just fine" do
      deserialized_collection = JSON.parse(@empty_collection.to_json)
      deserialized_collection.should be_empty
    end
  end
end
