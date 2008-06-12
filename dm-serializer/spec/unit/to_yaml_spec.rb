require 'pathname'
require 'yaml'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_yaml' do
  #
  # ==== yummy YAML
  #

  before(:all) do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

    @collection = DataMapper::Collection.new(query) do |c|
      c.load([1, 2, 'Betsy', 'Jersey'])
      c.load([10, 20, 'Berta', 'Guernsey'])
    end

    @empty_collection = DataMapper::Collection.new(query) {}
  end

  it "serializes single resource to YAML" do
    betsy = Cow.new(:id => 230, :composite => 22, :name => "Betsy", :breed => "Jersey")
    deserialized_hash = YAML.load(betsy.to_yaml)

    deserialized_hash[:id].should        == 230
    deserialized_hash[:name].should      == "Betsy"
    deserialized_hash[:composite].should == 22
    deserialized_hash[:breed].should     == "Jersey"
  end

  it "leaves out nil properties" do
    betsy = Cow.new(:id => 230, :name => "Betsy", :breed => "Jersey")
    deserialized_hash = YAML.load(betsy.to_yaml)

    deserialized_hash[:id].should        == 230
    deserialized_hash[:name].should      == "Betsy"
    deserialized_hash[:composite].should be(nil)
    deserialized_hash[:breed].should     == "Jersey"
  end

  it "serializes a collection to YAML" do
    deserialized_collection = YAML.load(@collection.to_yaml)

    betsy = deserialized_collection.first
    berta = deserialized_collection.last

    betsy[:id].should        == 1
    betsy[:name].should      == "Betsy"
    betsy[:composite].should == 2
    betsy[:breed].should     == "Jersey"

    berta[:id].should        == 10
    berta[:name].should      == "Berta"
    berta[:composite].should == 20
    berta[:breed].should     == "Guernsey"
  end

  it "handles empty collections just fine" do
    YAML.load(@empty_collection.to_yaml).should be_empty
  end

end
