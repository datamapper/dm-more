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
        value = value.to_i if type == "integer"
        value
      end
    end.new
  end

  it_should_behave_like "A serialization method"

end
