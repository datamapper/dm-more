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

    @empty_collection = DataMapper::Collection.new(query) {}
    @harness = Class.new do
      def method_name
        :to_json
      end

      def extract_value(result, key, options = {})
        if options[:index]
          JSON.parse(result)[options[:index]][key]
        else
          JSON.parse(result)[key]
        end
      end
    end.new
  end

  before(:each) do
    Cow.all.destroy!
    Planet.all.destroy!
    FriendedPlanet.all.destroy!
  end

  it_should_behave_like "A serialization method"

  it "serializes a one to many relationship" do
    parent = Cow.new(:id => 1, :composite => 322, :name => "Harry", :breed => "Angus")
    baby = Cow.new(:mother_cow => parent, :id => 2, :composite => 321, :name => "Felix", :breed => "Angus")

    parent.save
    baby.save

    deserialized_hash = JSON.parse(parent.baby_cows.to_json).first

    deserialized_hash["id"].should        == 2
    deserialized_hash["composite"].should == 321
    deserialized_hash["name"].should      == "Felix"
    deserialized_hash["breed"].should     == "Angus"
  end

  it "serializes a many to one relationship" do
    parent = Cow.new(:id => 1, :composite => 322, :name => "Harry", :breed => "Angus")
    baby = Cow.new(:mother_cow => parent, :id => 2, :composite => 321, :name => "Felix", :breed => "Angus")

    parent.save
    baby.save

    deserialized_hash = JSON.parse(baby.mother_cow.to_json)

    deserialized_hash["id"].should        == 1
    deserialized_hash["composite"].should == 322
    deserialized_hash["name"].should      == "Harry"
    deserialized_hash["breed"].should     == "Angus"
  end

  it "serializes a many to many relationship" do
    p1 = Planet.create(:name => 'earth')
    p2 = Planet.create(:name => 'mars')

    FriendedPlanet.create(:planet => p1, :friend_planet => p2)

    deserialized_hash = JSON.parse(p1.reload.friend_planets.to_json).first

    deserialized_hash["name"].should == "mars"
  end

  it "excludes nil attributes" do
    deserialized_hash = JSON.parse(Cow.new(:id => 1, :name => "Harry", :breed => "Angus").to_json)

    deserialized_hash["id"].should        == 1
    deserialized_hash["composite"].should be(nil)
    deserialized_hash["name"].should      == "Harry"
    deserialized_hash["breed"].should     == "Angus"
  end

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

  describe "multiple repositories" do
    before(:all) do
      QuantumCat.auto_migrate!
      repository(:alternate){QuantumCat.auto_migrate!}
    end

    it "should use the repsoitory for the model" do
      gerry = QuantumCat.create(:name => "gerry")
      george = repository(:alternate){QuantumCat.create(:name => "george", :is_dead => false)}
      gerry.to_json.should_not match(/is_dead/)
      george.to_json.should match(/is_dead/)
    end
  end

  it "supports :include option for one level depth"

  it "supports :include option for more than one level depth"

  it "has :repository option to override used repository"

end
