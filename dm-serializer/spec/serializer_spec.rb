require 'rubygems'
require 'pathname'
gem 'dm-core', '=0.9.0'
require 'data_mapper'

require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-serializer'


describe DataMapper::Serialize do

  before(:all) do
    class Cow
      include DataMapper::Resource    
      include DataMapper::Serialize
      property :id, Fixnum, :key => true
      property :composite, Fixnum, :key => true
      property :name, String
      property :breed, String
    end
  end
  
  
  it "should serialize a resource to YAML" do
    betsy = Cow.new
    betsy.id = 230
    betsy.composite = 22
    betsy.name = 'Betsy'
    betsy.breed = 'Jersey'
    betsy.to_yaml.strip.should == <<-EOS.margin
      --- 
      :id: 230
      :composite: 22
      :name: Betsy
      :breed: Jersey
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
  
  it "should serialize a resource to CSV" do
    peter = Cow.new
    peter.id = 44
    peter.composite = 344
    peter.name = 'Peter'
    peter.breed = 'Long Horn'    
    peter.to_csv.chomp.should == '44,344,Peter,Long Horn'
  end
  
  


end
