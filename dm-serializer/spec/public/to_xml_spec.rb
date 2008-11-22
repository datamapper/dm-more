require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_xml' do
  #
  # ==== enterprisey XML
  #

  before(:all) do
    @harness = Class.new(SerializerTestHarness) do
      def method_name
        :to_xml
      end

      protected

      def deserialize(result)
        doc = REXML::Document.new(result)
        root = doc.elements[1]
        if root.attributes["type"] == "array"
          root.elements.collect do |element|
            a = {}
            element.elements.each do |v|
              a.update(v.name => cast(v.text, v.attributes["type"]))
            end
            a
          end
        else  
          a = {}
          root.elements.each do |v|
            a.update(v.name => cast(v.text, v.attributes["type"]))
          end
          a
        end
      end

      def cast(value, type)
        boolean_conversions = {"true" => true, "false" => false}
        value = boolean_conversions[value] if boolean_conversions.has_key?(value)
        value = value.to_i if value && type == "integer"
        value
      end
    end.new
  end

  it_should_behave_like "A serialization method"

  describe 'Resource#xml_element_name' do
    it 'should return the class name underscored by extlib' do
      QuantumCat.new.send(:xml_element_name).should == Extlib::Inflection.underscore('QuantumCat')
    end

    it 'should be used as the root node name by #to_xml' do
      planet = Planet.new
      class << planet
        def xml_element_name
          "aplanet"
        end
      end

      xml = planet.to_xml
      REXML::Document.new(xml).elements[1].name.should == "aplanet"
    end
  end

  describe 'Collection#xml_element_name' do
    before(:each) do
      query = DataMapper::Query.new(DataMapper::repository(:default), QuantumCat)
      @collection = DataMapper::Collection.new(query) {}
    end

    it 'should return the class name tableized by extlib' do
      @collection.send(:xml_element_name).should == Extlib::Inflection.tableize('QuantumCat')
    end

    it 'should be used as the root node name by #to_xml' do
      planet = Planet.new
      @collection.load([1])
      class << @collection
        def xml_element_name
          "somanycats"
        end
      end

      xml = @collection.to_xml
      REXML::Document.new(xml).elements[1].name.should == "somanycats"
    end
  end
end
