require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname + 'rest_adapter/version'
gem 'dm-core', DataMapper::More::RestAdapter::VERSION
require 'dm-core'

gem 'extlib', '>=0.9.5'
require 'extlib'

require 'dm-serializer'
require 'net/http'
require 'rexml/document'

# TODO: Abstract XML support out from the protocol
# TODO: Build JSON support
module DataMapper
  module Adapters
    class RestAdapter < AbstractAdapter
      include Extlib

      # Creates a new resource in the specified repository.
      def create(resources)
        count = 0
        resources.each do |resource|
          resource_name = Inflection.underscore(resource.class.name)
          result = http_post("/#{resource_name.pluralize}.xml", resource.to_xml)
          # TODO: Raise error if cannot reach server
          success = result.instance_of?(Net::HTTPCreated)
          if success
            count += 1
            # TODO: Fix commented out code below to work through the identity_map of the repository
            # values = parse_resource(result.body, resource.class)
            # resource.id = updated_resource.id
          end
          # TODO: We're not using the response to update the DataMapper::Resource with the newly acquired ID!!!
        end
        count
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
        resource_name = Inflection.underscore(query.model.name)
        Collection.new(query) do |collection|
          case query.conditions
          when []
            resources_meta = read_set_all(repository, query, resource_name)
          else
            resources_meta = read_set_for_condition(repository, query, resource_name)
          end
          resources_meta.each do |resource_meta|
            if resource_meta.has_key?(:associations)
              load_nested_resources_from resource_meta[:associations], query
            end
            collection.load(resource_meta[:values])
          end
        end
      end

      def read_one(query)
        resource = nil
        resource_name = resource_name_from_query(query)
        resources_meta = nil
        if query.conditions.empty? && query.limit == 1
          results = read_set_all(repository, query, resource_name)
          resource_meta = results.first unless results.empty?
        else
          id = query.conditions.first[2]
          # KLUGE: Again, we're assuming below that we're dealing with a pluralized resource mapping

          response = http_get("/#{resource_name.pluralize}/#{id}.xml")

          # KLUGE: Rails returns HTML if it can't find a resource.  A properly RESTful app would return a 404, right?
          return nil if response.is_a? Net::HTTPNotFound || response.content_type == "text/html"

          data = response.body
          resource_meta = parse_resource(data, query.model, query)
        end
        if resource_meta
          if resource_meta.has_key?(:associations)
            load_nested_resources_from resource_meta[:associations], query
          end
          resource = query.model.load(resource_meta[:values], query)
        end
        resource
      end

      def update(attributes, query)
        # TODO What if we have a compound key?
        raise NotImplementedError.new unless is_single_resource_query? query
        id = query.conditions.first[2]
        resource = nil
        query.repository.scope do
          resource = query.model.get(id)
        end
        attributes.each do |attr, val|
          resource.send("#{attr.name}=", val)
        end
        # KLUGE: Again, we're assuming below that we're dealing with a pluralized resource mapping
        res = http_put("/#{resource_name_from_query(query).pluralize}/#{id}.xml", resource.to_xml)
        # TODO: Raise error if cannot reach server
        res.kind_of?(Net::HTTPSuccess) ? 1 : 0
      end

      def delete(query)
        raise NotImplementedError.new unless is_single_resource_query? query
        id = query.conditions.first[2]
        res = http_delete("/#{resource_name_from_query(query).pluralize}/#{id}.xml")
        res.kind_of?(Net::HTTPSuccess) ? 1 : 0
      end

    protected
      def load_nested_resources_from(nested_resources, query)
        nested_resources.each do |resource_meta|
          # TODO: Houston, we have a problem.  Model#load expects a Query.  When we're nested, we don't have a query yet...
          #resource_meta[:model].load(resource_meta[:values])
          #if resource_meta.has_key? :associations
          #  load_nested_resources_from resource_meta, query
          #end
        end
      end

      def read_set_all(repository, query, resource_name)
        # TODO: how do we know whether the resource we're talking to is singular or plural?
        res = http_get("/#{resource_name.pluralize}.xml")
        data = res.body
        parse_resources(data, query.model, query)
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
        request do |http|
          request = Net::HTTP::Put.new(uri, data)
          request.basic_auth(@uri[:login], @uri[:password]) unless @uri[:login].blank?
          http.request(request)
        end
      end

      def http_post(uri, data)
        request do |http|
          request = Net::HTTP::Post.new(uri, data, {"Content-Type", "application/xml"})
          request.basic_auth(@uri[:login], @uri[:password]) unless @uri[:login].blank?
          http.request(request)
        end
      end

      def http_get(uri)
        request do |http|
          request = Net::HTTP::Get.new(uri)
          request.basic_auth(@uri[:login], @uri[:password]) unless @uri[:login].blank?
          http.request(request)
        end
      end

      def http_delete(uri)
        request do |http|
          request = Net::HTTP::Delete.new(uri)
          request.basic_auth(@uri[:login], @uri[:password]) unless @uri[:login].blank?
          http.request(request)
        end
      end

      def request(&block)
        res = nil
        Net::HTTP.start(@uri[:host], @uri[:port].to_i) do |http|
          res = yield(http)
        end
        res
      end

      def values_from_rexml(entity_element, dm_model_class)
        resource = {}
        resource[:values] = []
        entity_element.elements.each do |field_element|
          attribute = dm_model_class.properties(repository.name).find do |property|
            # *MUST* use Inflection.underscore on the XML as Rails converts '_' to '-' in the XML
            property.name.to_s == Inflection.underscore(field_element.name.to_s)
          end
          if attribute
            resource[:values] << field_element.text
            next
          end
          association = dm_model_class.relationships.find do |name, dm_relationship|
            field_element.name.to_s == Inflection.pluralize(Inflection.underscore(dm_relationship.child_model.to_s))
          end
          if association
            field_element.each_element do |associated_element|
              model = association[1].child_model
              (resource[:associations] ||= []) << {
                :model => model,
                :value => values_from_rexml(associated_element, association[1].child_model)
              }
            end
          end
        end
        resource
      end

      def parse_resource(xml, dm_model_class, query = nil)
        doc = REXML::Document::new(xml)
        # TODO: handle singular resource case as well....
        entity_element = REXML::XPath.first(doc, "/#{resource_name_from_model(dm_model_class)}")
        return nil unless entity_element
        values_from_rexml(entity_element, dm_model_class)
      end

      def parse_resources(xml, dm_model_class, query = nil)
        doc = REXML::Document::new(xml)
        # # TODO: handle singular resource case as well....
        # array = XPath(doc, "/*[@type='array']")
        # if array
        #   parse_resources()
        # else
        resource_name = resource_name_from_model dm_model_class
        doc.elements.collect("#{resource_name.pluralize}/#{resource_name}") do |entity_element|
          values_from_rexml(entity_element, dm_model_class)
        end
      end

      def resource_name_from_model(model)
        Inflection.underscore(model.name)
      end

      def resource_name_from_query(query)
        resource_name_from_model(query.model)
      end
    end
  end
end
