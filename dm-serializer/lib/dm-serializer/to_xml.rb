require 'dm-serializer/common'
require 'dm-serializer/xml_serializers'
require 'rexml/document'

module DataMapper
  module Serialize
    # Serialize a Resource to XML
    #
    # @return <REXML::Document> an XML representation of this Resource
    def to_xml(opts = {})
      xml = XMLSerializers::SERIALIZER
      xml.output(to_xml_document(opts)).to_s
    end

    # This method requires certain methods to be implemented in the individual
    # serializer library subclasses:
    # new_document
    # root_node
    # add_property_node
    # add_node
    def to_xml_document(opts={}, doc = nil)
      xml = XMLSerializers::SERIALIZER
      doc ||= xml.new_document
      default_xml_element_name = lambda { Extlib::Inflection.underscore(model.name).tr("/", "-") }
      root = xml.root_node(doc, opts[:element_name] || default_xml_element_name[])
      properties_to_serialize(opts).each do |property|
        value = __send__(property.name)
        attrs = (property.type == String) ? {} : {'type' => property.type.to_s.downcase}
        xml.add_node(root, property.name.to_s, value, attrs)
      end

      (opts[:methods] || []).each do |meth|
        if self.respond_to?(meth)
          xml_name = meth.to_s.gsub(/[^a-z0-9_]/, '')
          value = __send__(meth)
          unless value.nil?
            if value.respond_to?(:to_xml_document)
              xml.add_xml(root, value.to_xml_document)
            else
              xml.add_node(root, xml_name, value.to_s)
            end
          end
        end
      end
      doc
    end
  end

  class Collection
    def to_xml(opts = {})
      to_xml_document(opts).to_s
    end

    def to_xml_document(opts = {})
      xml = DataMapper::Serialize::XMLSerializers::SERIALIZER
      doc = xml.new_document
      default_collection_element_name = lambda {Extlib::Inflection.pluralize(Extlib::Inflection.underscore(self.model.to_s)).tr("/", "-")}
      root = xml.root_node(doc, opts[:collection_element_name] || default_collection_element_name[], {'type' => 'array'})
      self.each do |item|
        item.to_xml_document(opts, doc)
      end
      doc
    end
  end

  if Serialize::Support.dm_validations_loaded?

    module Validate
      class ValidationErrors
        def to_xml(opts = {})
          to_xml_document(opts).to_s
        end

        def to_xml_document(opts = {})
          xml = DataMapper::Serialize::XMLSerializers::SERIALIZER
          doc = xml.new_document
          root = xml.root_node(doc, "errors", {'type' => 'hash'})

          errors.each do |key, value|
            property = xml.add_node(root, key.to_s, nil, {'type' => 'array'})
            property.attributes["type"] = 'array'
            value.each do |error|
              xml.add_node(property, "error", error)
            end
          end

          doc
        end
      end
    end

  end
end
