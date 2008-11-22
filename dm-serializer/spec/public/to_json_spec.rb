require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_json' do
  #
  # ==== ajaxy JSON
  #

  before(:all) do
    DataMapper.auto_migrate!
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

    @collection = DataMapper::Collection.new(query) do |c|
      c.load([1, 2, 'Betsy', 'Jersey'])
      c.load([10, 20, 'Berta', 'Guernsey'])
    end

    @harness = Class.new(SerializerTestHarness) do
      def method_name
        :to_json
      end

      protected

      def deserialize(result)
        JSON.parse(result)
      end
    end.new
  end

  it_should_behave_like "A serialization method"

  it "should serialize an array of collections" do
    deserialized_collection = JSON.parse([@collection].to_json).first
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

  it "should serialize an array of extended objects" do
    deserialized_collection = JSON.parse(@collection.to_a.to_json)
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

  it "handles extra properties" do
    deserialized_hash = JSON.parse(Cow.new(:id => 1, :name => "Harry", :breed => "Angus").to_json)

    deserialized_hash["extra"].should == "Extra"
    deserialized_hash["another"].should == 42
  end

  it "handles options given to a collection properly" do
    deserialized_collection = JSON.parse(@collection.to_json(:only => [:composite]))
    betsy = deserialized_collection.first
    berta = deserialized_collection.last

    betsy["id"].should be_nil
    betsy["composite"].should == 2
    betsy["name"].should be_nil
    betsy["breed"].should be_nil

    berta["id"].should be_nil
    berta["composite"].should == 20
    berta["name"].should be_nil
    berta["breed"].should be_nil
  end

  it "supports :include option for one level depth"

  it "supports :include option for more than one level depth"

  it "has :repository option to override used repository"

end
