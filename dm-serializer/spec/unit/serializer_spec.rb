require 'pathname'
require 'yaml'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize do

  before(:all) do
    class Cow
      include DataMapper::Resource
      property :id, Integer, :key => true
      property :composite, Integer, :key => true
      property :name, String
      property :breed, String
    end

    properties = Cow.properties(:default)
    properties_with_indexes = Hash[*properties.zip((0...properties.length).to_a).flatten]
    @collection = DataMapper::Collection.new(DataMapper::repository(:default), Cow, properties_with_indexes)
    @collection.load([1, 2, 'Betsy', 'Jersey'])
    @collection.load([10, 20, 'Berta', 'Guernsey'])

  end

  it "should serialize a resource to YAML" do
    betsy = Cow.new
    betsy.id = 230
    betsy.composite = 22
    betsy.name = 'Betsy'
    betsy.breed = 'Jersey'
    betsy.to_yaml.gsub(/[[:space:]]+\n/, "\n").strip.should == <<-EOS.margin
      ---
      :id: 230
      :composite: 22
      :name: Betsy
      :breed: Jersey
    EOS
  end

  it "should serialize a collection to YAML" do
    @collection.to_yaml.gsub(/[[:space:]]+\n/, "\n").strip.should == <<-EOS.margin
      ---
      - :id: 1
        :composite: 2
        :name: Betsy
        :breed: Jersey
      - :id: 10
        :composite: 20
        :name: Berta
        :breed: Guernsey
    EOS

  end

  it "should serialize a resource to XML" do
    berta = Cow.new
    berta.id = 89
    berta.composite = 34
    berta.name = 'Berta'
    berta.breed = 'Guernsey'

    berta.to_xml.should == <<-EOS.compress_lines(false)
      <cow composite='34' id='89'>
        <name>Berta</name>
        <breed>Guernsey</breed>
      </cow>
    EOS
  end

  it "should serialize a resource to JSON" do
    harry = Cow.new
    harry.id = 1
    harry.composite = 322
    harry.name = 'Harry'
    harry.breed = 'Angus'
    harry.to_json.should == <<-EOS.compress_lines
      {
        "id": 1,
        "composite": 322,
        "name": "Harry",
        "breed": "Angus"
      }
    EOS
  end

  it "should serialize a collection to JSON" do
    @collection.to_json.gsub(/[[:space:]]+\n/, "\n").strip.should ==
      '[{ "id": 1, "composite": 2, "name": "Betsy", "breed": "Jersey" },' +
      '{ "id": 10, "composite": 20, "name": "Berta", "breed": "Guernsey" }]'
  end


  it "should serialize a resource to CSV" do
    peter = Cow.new
    peter.id = 44
    peter.composite = 344
    peter.name = 'Peter'
    peter.breed = 'Long Horn'
    peter.to_csv.chomp.should == '44,344,Peter,Long Horn'
  end

end
