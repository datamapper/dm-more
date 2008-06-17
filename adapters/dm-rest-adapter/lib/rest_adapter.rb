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
        success = true
        resources.each do |resource|
          resource_name = Inflection.underscore(resource.class.name.downcase)
          result = http_post("/#{resource_name.pluralize}.xml", resource.to_xml)
          # TODO: Raise error if cannot reach server
          success = success && result.instance_of?(Net::HTTPCreated)
          if success
            updated_resource = parse_resource(result.body, resource.class)
            resource.id = updated_resource.id
          end
          # TODO: We're not using the response to update the DataMapper::Resource with the newly acquired ID!!!
        end
        success
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
        # puts "---------------- QUERY: #{query} #{query.inspect}"
        id = query.conditions.first[2]
        # KLUGE: Again, we're assuming below that we're dealing with a pluralized resource mapping
        resource_name = resource_name_from_query(query)
        response = http_get("/#{resource_name.pluralize}/#{id}.xml")
        
        # KLUGE: Rails returns HTML if it can't find a resource.  A properly RESTful app would return a 404, right?
        return nil if response.is_a? Net::HTTPNotFound || response.content_type == "text/html"
        
        data = response.body
        res = parse_resource(data, query.model)
        res
      end
      
      def update(attributes, query)
        # TODO update for v0.9.2
        raise NotImplementedError.new unless is_single_resource_query? query
        id = query.conditions.first[2]
        resource = query.model.new
        attributes.each do |attr, val|
          resource.send("#{attr.name}=", val)
        end
        # KLUGE: Again, we're assuming below that we're dealing with a pluralized resource mapping
        http_put("/#{resource_name_from_query(query).pluralize}/#{id}.xml", resource.to_xml)
        # TODO: Raise error if cannot reach server
      end
      
      def delete(query)
        #puts ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>> QUERY: #{query} #{query.inspect}"
        # TODO update for v0.9.2
        raise NotImplementedError.new unless is_single_resource_query? query
        id = query.conditions.first[2]
        http_delete("/#{resource_name_from_query(query).pluralize}/#{id}.xml")
      end
      
    protected
      def read_set_all(repository, query, resource_name)
        # TODO: how do we know whether the resource we're talking to is singular or plural?
        res = http_get("/#{resource_name.pluralize}.xml")
        data = res.body
        parse_resources(data, query.model)
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

      def resource_from_rexml(entity_element, dm_model_class)
        resource = dm_model_class.new
        entity_element.elements.each do |field_element|
          attribute = resource.attributes.find do |name, val| 
            # *MUST* use Inflection.underscore on the XML as Rails converts '_' to '-' in the XML
            name.to_s == Inflection.underscore(field_element.name.to_s)
          end
          resource.send("#{Inflection.underscore(attribute[0])}=", field_element.text) if attribute
        end
        resource.instance_eval { @new_record= false }
        resource
      end

      def parse_resource(xml, dm_model_class)
        doc = REXML::Document::new(xml)
        # TODO: handle singular resource case as well....
        entity_element = REXML::XPath.first(doc, "/#{resource_name_from_model(dm_model_class)}")
        return nil unless entity_element
        resource_from_rexml(entity_element, dm_model_class)
      end
      
      def parse_resources(xml, dm_model_class)
        doc = REXML::Document::new(xml)
        # # TODO: handle singular resource case as well....
        # array = XPath(doc, "/*[@type='array']")
        # if array
        #   parse_resources()
        # else
        resource_name = resource_name_from_model dm_model_class
        doc.elements.collect("#{resource_name.pluralize}/#{resource_name}") do |entity_element|
          resource_from_rexml(entity_element, dm_model_class)
        end
      end  
      
      def resource_name_from_model(model)
        Inflection.underscore(model.name.downcase)
      end
      
      def resource_name_from_query(query)
        resource_name_from_model(query.model)
      end
    end
  end
end