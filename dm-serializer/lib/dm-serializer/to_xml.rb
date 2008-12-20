require 'dm-serializer/common'
require 'rexml/document'

module DataMapper
  module Serialize
    # Serialize a Resource to XML
    #
    # @return <REXML::Document> an XML representation of this Resource
    def to_xml(opts = {})
      to_xml_document(opts).to_s
    end

    protected

    # Return the name of this Resource - to be used as the root element name.
    # This can be overloaded.
    #
    # @return <String> name of this Resource
    def xml_element_name
      Extlib::Inflection.underscore(self.class.name).tr("/", "-")
    end

    # Return a REXML::Document representing this Resource
    #
    # @return <REXML::Document> an XML representation of this Resource
    def to_xml_document(opts={}, doc=nil)
      doc ||= REXML::Document.new
      root = doc.add_element(xml_element_name)

      #TODO old code base was converting single quote to double quote on attribs

      propset = properties_to_serialize(opts)
      propset.each do |property|
          value = send(property.name)
          node = root.add_element(property.name.to_s)
          unless property.type == String
            node.attributes["type"] = property.type.to_s.downcase
          end
          node << REXML::Text.new(value.to_s) unless value.nil?
      end

      # add methods
      (opts[:methods] || []).each do |meth|
        if self.respond_to?(meth)
          xml_name = meth.to_s.gsub(/[^a-z0-9_]/, '')
          node = root.add_element(xml_name)
          value = send(meth)
          node << REXML::Text.new(value.to_s, :raw => true) unless value.nil?
        end
      end
      doc
    end
  end

  class Collection
    def to_xml(opts = {})
      to_xml_document(opts).to_s
    end

    protected

    def xml_element_name
      Extlib::Inflection.pluralize(Extlib::Inflection.underscore(self.model.to_s)).tr("/", "-")
    end

    def to_xml_document(opts={})
      doc = REXML::Document.new
      root = doc.add_element(xml_element_name)
      root.attributes["type"] = 'array'
      each do |item|
        item.send(:to_xml_document, opts, root)
      end
      doc
    end
  end
end
