require 'rubygems'
gem 'dm-core', '=0.9.2'
require 'dm-core'
require 'extlib'
require 'dm-serializer'
require 'pathname'
require 'net/http'
require 'rexml/document'

# TODO: Abstract XML support out from the protocol
# TODO: Build JSON support
module DataMapper
  module Adapters
    class RestAdapter < AbstractAdapter
      include Extlib

      # def read_one(query)
      #   raise NotImplementedError
      # end
      # 
      # def update(attributes, query)
      #   raise NotImplementedError
      # end
      # 
      # def delete(query)
      #   raise NotImplementedError
      # end
      
      # Creates a new resource in the specified repository.
      def create(resources)
        resources.each do |resource|
          resource_name = Inflection.underscore(resource.class.name.downcase)
          result = http_post("/#{resource_name.pluralize}.xml", resource.to_xml)
          # TODO: Raise error if cannot reach server
          result.kind_of? Net::HTTPSuccess
          # TODO: We're not using the response to update the DataMapper::Resource with the newly acquired ID!!!
        end
      end
      
      # read_set
      #
      # Examples of query string:
      # A. []
      #    GET /books/
      #
      # B. [[:eql, #<Property:Book:id>, 4200]]
      #    GET /books/4200
      #
      # IN PROGRESS
      # TODO: Need to account for query.conditions (i.e., [[:eql, #<Property:Book:id>, 1]] for books/1)
      def read_many(query)
        resource_name = Inflection.underscore(query.model.name.downcase)
        case query.conditions
        when []
          read_set_all(repository, query, resource_name)
        else
          read_set_for_condition(repository, query, resource)
        end
      end
      
      def read_one(query)
        id = query.conditions.first[2]
        # KLUGE: Again, we're assuming below that we're dealing with a pluralized resource mapping
        resource_name = Inflection.underscore(query.model.name.downcase)
        res = http_get("/#{resource_name.pluralize}/#{id}.xml")
        
        # KLUGE: Rails returns HTML if it can't find a resource.  A properly RESTful app would return a 404, right?
        return nil if res.is_a? Net::HTTPNotFound || res.content_type == "text/html"
        
        data = res.body
        res = parse_resource(data, resource_name, query.model, query.fields)
        res
      end
      
      def update(attributes, query)
        # TODO update for v0.9.2
        http_put("/#{resource.class.storage_name}.xml", resource.to_xml)
        # TODO: Raise error if cannot reach server
      end
      
      def delete(query)
        # TODO update for v0.9.2
        http_delete("/#{resource.class.storage_name}.xml")
        # TODO: Raise error if cannot reach server
      end
      
    protected
      def read_set_all(repository, query, resource_name)
        # TODO: how do we know whether the resource we're talking to is singular or plural?
        res = http_get("/#{resource_name.pluralize}.xml")
        data = res.body
        parse_resources(data, resource_name, query.model, query.fields)
        # TODO: Raise error if cannot reach server
      end
      
      #    GET /books/4200
      def read_set_for_condition(repository, query, resource_name)
        # More complex conditions
        raise NotImplementedError.new
      end    
          
      # query.conditions like [[:eql, #<Property:Book:id>, 4200]]
      def is_single_resource_query?(query)
        query.conditions.length == 1 && query.conditions.first.first == :eql && query.conditions.first[1].name == :id
      end
      
      def http_put(uri, data = nil)
        request { |http| http.put(uri, data) }
      end

      def http_post(uri, data)
        request { |http| http.post(uri, data, {"Content-Type", "application/xml"}) }
      end

      def http_get(uri)
        request { |http| http.get(uri) }
      end

      def http_delete(uri)
        request { |http| http.delete(uri) }
      end

      def request(&block)
        res = nil
        Net::HTTP.start(@uri[:host], @uri[:port].to_i) do |http|
          res = yield(http)
        end
        res
      end  

      def resource_from_rexml(entity_element, dm_model_class, dm_properties)
        resource = dm_model_class.new
        entity_element.elements.each do |field_element|
          dm_property = dm_properties.find do |p| 
            # *MUST* use Inflection.underscore on the XML as Rails converts '_' to '-' in the XML
            p.name.to_s == Inflection.underscore(field_element.name.to_s)
          end
          resource.send("#{Inflection.underscore(dm_property.name)}=", field_element.text) if dm_property
        end
        resource
      end

      def parse_resource(xml, resource_name, dm_model_class, dm_properties)
        doc = REXML::Document::new(xml)
        # TODO: handle singular resource case as well....
        entity_element = REXML::XPath.first(doc, "/#{resource_name}")
        return nil unless entity_element
        resource_from_rexml(entity_element, dm_model_class, dm_properties)
      end
      
      def parse_resources(xml, resource_name, dm_model_class, dm_properties)
        doc = REXML::Document::new(xml)
        # # TODO: handle singular resource case as well....
        # array = XPath(doc, "/*[@type='array']")
        # if array
        #   parse_resources()
        # else
          
        doc.elements.collect("#{resource_name.pluralize}/#{resource_name}") do |entity_element|
          resource_from_rexml(entity_element, dm_model_class, dm_properties)
        end
      end  
    end
  end
end