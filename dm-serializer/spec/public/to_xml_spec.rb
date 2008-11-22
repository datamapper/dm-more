require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe DataMapper::Serialize, '#to_xml' do
  #
  # ==== enterprisey XML
  #

  before(:all) do
    @harness = Class.new do
      def method_name
        :to_xml
      end

      def extract_value(result, key, options = {})
        doc = REXML::Document.new(result)
        if options[:index]
          element = doc.elements[1].elements[options[:index] + 1].elements[key]
        else
          element = doc.elements[1].elements[key]
        end
        value = element ? element.text : nil
        attributes = element ? element.attributes : {}
        boolean_conversions = {"true" => true, "false" => false}
        value = boolean_conversions[value] if boolean_conversions.has_key?(value)
        value = value.to_i if attributes["type"] == "integer"
        value
      end

      def cast(value, type)
        boolean_conversions = {"true" => true, "false" => false}
        value = boolean_conversions[value] if boolean_conversions.has_key?(value)
        value = value.to_i if type == "integer"
        value
      end

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
          raise "Unimplemented - XML deserialize for non array"
        end
      end
    end.new
  end

  it_should_behave_like "A serialization method"

  describe "multiple repositories" do
    before(:all) do
      QuantumCat.auto_migrate!
      repository(:alternate){QuantumCat.auto_migrate!}
    end

    it "should use the repsoitory for the model" do
      gerry = QuantumCat.create(:name => "gerry")
      george = repository(:alternate){QuantumCat.create(:name => "george", :is_dead => false)}
      gerry.to_xml.should_not match(/is_dead/)
      george.to_xml.should match(/is_dead/)
    end
  end

end
