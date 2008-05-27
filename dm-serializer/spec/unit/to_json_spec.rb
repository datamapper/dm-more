require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'


describe DataMapper::Serialize do
  before(:all) do
    properties = Cow.properties(:default)
    properties_with_indexes = Hash[*properties.zip((0...properties.length).to_a).flatten]
    @collection = DataMapper::Collection.new(DataMapper::repository(:default), Cow, properties_with_indexes)
    @collection.load([1, 2, 'Betsy', 'Jersey'])
    @collection.load([10, 20, 'Berta', 'Guernsey'])
  end

  #
  # ==== ajaxy JSON
  #

  describe "#to_json" do
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
  end
end  
