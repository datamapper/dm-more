require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_json' do
  #
  # ==== ajaxy JSON
  #

  before(:all) do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

    @collection = DataMapper::Collection.new(query) do |c|
      c.load([1, 2, 'Betsy', 'Jersey'])
      c.load([10, 20, 'Berta', 'Guernsey'])
    end

    @empty_collection = DataMapper::Collection.new(query) {}
  end

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

  it "serializes values returned by methods given to :methods option" do
    deserialized_hash = JSON.parse(Planet.new(:name => "Mars", :aphelion => 249_209_300.4).to_json(:methods => [:category, :has_known_form_of_life?]))

    deserialized_hash["category"].should == "terrestrial"
    deserialized_hash["has_known_form_of_life?"].should be(false)
  end

  it "only includes properties given to :only option" do
    deserialized_hash = JSON.parse(Planet.new(:name => "Mars", :aphelion => 249_209_300.4).to_json(:only => [:name]))

    deserialized_hash["name"].should == "Mars"
    deserialized_hash["aphelion"].should be(nil)
  end

  it "only includes properties given to :only option" do
    deserialized_hash = JSON.parse(Planet.new(:name => "Mars", :aphelion => 249_209_300.4).to_json(:exclude => [:aphelion]))

    deserialized_hash["name"].should == "Mars"
    deserialized_hash["aphelion"].should be(nil)
  end

  it "has higher presedence for :only option" do
    deserialized_hash = JSON.parse(Planet.new(:name => "Mars", :aphelion => 249_209_300.4).to_json(:only => [:aphelion], :exclude => [:aphelion]))

    deserialized_hash["name"].should be(nil)
    deserialized_hash["aphelion"].should == 249_209_300.4
  end

  it "supports :include option for one level depth"

  it "supports :include option for more than one level depth"

  it "has :repository option to override used repository"

end
