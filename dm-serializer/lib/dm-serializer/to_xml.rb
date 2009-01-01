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
     
    if defined?(::LibXML)
      def to_xml_document(opts={}, doc=nil)
        doc ||= ::LibXML::XML::Document.new
        default_xml_element_name = lambda { Extlib::Inflection.underscore(self.class.name).tr("/", "-") }
        root = ::LibXML::XML::Node.new(opts[:element_name] || default_xml_element_name[])
        doc.root.nil? ? doc.root = root :
                        doc.root << root
        properties_to_serialize(opts).each do |property|
          value = send(property.name)
          root << node = ::LibXML::XML::Node.new(property.name.to_s)
          if property.key?
            node["type"] = property.type.to_s.downcase
          end          
          node << value.to_s unless value.nil?
        end

        # add methods
        (opts[:methods] || []).each do |meth|
          if self.respond_to?(meth)
            xml_name = meth.to_s.gsub(/[^a-z0-9_]/, '')
            value = send(meth)
            root << ::LibXML::XML::Node.new(xml_name, value.to_s) unless value.nil?
          end
        end

        doc      
      end
    else
      require 'rexml/document'

      # Return a REXML::Document representing this Resource
      #
      # @return <REXML::Document> an XML representation of this Resource
      def to_xml_document(opts={}, doc=nil)
        doc ||= REXML::Document.new
        default_xml_element_name = lambda { Extlib::Inflection.underscore(self.class.name).tr("/", "-") }
        root = doc.add_element(opts[:element_name] || default_xml_element_name[])

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
  end

  class Collection
    def to_xml(opts = {})
      to_xml_document(opts).to_s
    end

    protected

    if defined?(::LibXML)
      def to_xml_document(opts={})
        doc = ::LibXML::XML::Document.new
        default_collection_element_name = lambda { Extlib::Inflection.pluralize(Extlib::Inflection.underscore(self.model.to_s)).tr("/", "-") }
        doc.root = root = ::LibXML::XML::Node.new(opts[:collection_element_name] || default_collection_element_name[])
        root['type'] = 'array'

        each do |item|
          item.send(:to_xml_document, opts, doc)
        end
        doc
      end
    else
      require 'rexml/document'
      def to_xml_document(opts={})
        doc = ::REXML::Document.new
        default_collection_element_name = lambda { Extlib::Inflection.pluralize(Extlib::Inflection.underscore(self.model.to_s)).tr("/", "-") }
        root = doc.add_element(opts[:collection_element_name] || default_collection_element_name[])

        root.attributes["type"] = 'array'
        each do |item|
          item.send(:to_xml_document, opts, root)
        end
        doc
      end
    end
  end
end
