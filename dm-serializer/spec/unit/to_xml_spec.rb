require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_xml' do
  #
  # ==== enterprisey XML
  #

  before(:all) do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)

    @collection = DataMapper::Collection.new(query)
    @collection.load([1, 2, 'Betsy', 'Jersey'])
    @collection.load([10, 20, 'Berta', 'Guernsey'])

    @empty_collection = DataMapper::Collection.new(query)
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

  it "should serialize a collection to XML" do
    @collection.to_xml.gsub(/[[:space:]]+\n/, "\n").should ==
      "<cow composite='2' id='1'><name>Betsy</name><breed>Jersey</breed></cow>\n" +
      "<cow composite='20' id='10'><name>Berta</name><breed>Guernsey</breed></cow>\n"
  end
end
