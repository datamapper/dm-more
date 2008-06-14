require 'rubygems'
gem 'dm-core', '=0.9.1'
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
      # Creates a new resource in the specified repository.
      def create(repository, resource)
        result = http_post("/#{resource.class.storage_name}.xml", resource.to_xml)
        # TODO: Raise error if cannot reach server
        result.kind_of? Net::HTTPSuccess
      end
      
      def read_set(repository, query)
        # puts query.inspect <- THIS WILL HELP YOU
        resource = query.model.name.downcase
        # TODO: how do we know whether the resource we're talking to is singular or plural?
        # TODO: Need to account for query.conditions (i.e., [[:eql, #<Property:Book:id>, 1]] for books/1)
        data = http_get("/#{resource.pluralize}.xml").body
        parse_resources(data, resource, query.model, query.fields)
        # TODO: Raise error if cannot reach server
      end
      
      def update(repository, resource)
        http_put("/#{resource.class.storage_name}.xml", resource.to_xml)
        # TODO: Raise error if cannot reach server
      end
      
      def delete(repository, resource)
        http_delete("/#{resource.class.storage_name}.xml")
        # TODO: Raise error if cannot reach server
      end
      
      
    protected
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
      
      def parse_resources(xml, resource_name, dm_model_class, dm_properties)
        doc = REXML::Document::new(xml)
        # TODO: handle singular resource case as well....
        doc.elements.collect("#{resource_name.pluralize}/#{resource_name}") do |entity_element|
          resource = dm_model_class.new
#          entity_element.elements
          entity_element.elements.each do |field_element|
            dm_property = dm_properties.find { |f| f.name.to_s == field_element.name.to_s }
            resource.send("#{dm_property.name}=", field_element.text) if dm_property
          end
          resource
        end
      end  
    end
  end
end