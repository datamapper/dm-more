require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_xml' do
  #
  # ==== enterprisey XML
  #

  before(:all) do
    query = DataMapper::Query.new(DataMapper::repository(:default), Cow)
    
    @time = DateTime.now
    

    @collection = DataMapper::Collection.new(query) do |c|
      c.load([1, 2, 'Betsy', 'Jersey'])
      c.load([10, 20, 'Berta', 'Guernsey'])
    end

    @empty_collection = DataMapper::Collection.new(query) {}
  end

  it "should serialize a resource to XML" do
    berta = Cow.new
    berta.id = 89
    berta.composite = 34
    berta.name = 'Berta'
    berta.breed = 'Guernsey'

    berta.to_xml.should == <<-EOS.compress_lines(false)
    <cow>
      <id type='integer'>89</id>
      <composite type='integer'>34</composite>
      <name>Berta</name>
      <breed>Guernsey</breed>
    </cow>
  EOS
  end

  it "should serialize a collection to XML" do
    @collection.to_xml.should == <<-EOS.compress_lines(false)
      <cows type='array'>
        <cow>
          <id type='integer'>1</id>
          <composite type='integer'>2</composite>
          <name>Betsy</name>
          <breed>Jersey</breed>
        </cow>
        <cow>
          <id type='integer'>10</id>
          <composite type='integer'>20</composite>
          <name>Berta</name>
          <breed>Guernsey</breed>
        </cow>
      </cows>
  EOS
  end
end
