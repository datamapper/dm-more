require 'rubygems'
gem 'dm-core'
require 'data_mapper'
require 'net/http'
require 'json'

class Time
  def to_json(*a)
    self.to_i.to_json(*a)
  end
end

module DataMapper
  module Adapters
    class CouchdbAdapter < AbstractAdapter
      
      def create(repository, resource)
        result = http_post("/#{resource.class.storage_name(name)}/", resource.to_json(true))
        resource.instance_variable_set("@rev", result["rev"])
        if result["ok"]
          key = resource.class.key(name)
          if key.size == 1
            resource.instance_variable_set(key.first.instance_variable_name, result["id"])
          end
          true
        else
          false
        end
      end
      
      def read(repository, resource, key)
        properties = resource.properties(repository.name).defaults
        properties_with_indexes = Hash[*properties.zip((0...properties.length).to_a).flatten]
        set = Collection.new(repository, resource, properties_with_indexes)
        
        doc = http_get("/#{resource.storage_name(name)}/#{key}")
        set.load(properties.map { |property| typecast(property.type, doc[property.field.to_s]) })
        
        set.first
      end
      
      def delete(repository, resource)
        key = resource.class.key(name).map { |property| resource.instance_variable_get(property.instance_variable_name) }
        result = http_delete("/#{resource.class.storage_name(name)}/#{key}?rev=#{resource.rev}")
        return result["ok"]
      end
      
      def update(repository, resource)
        key = resource.class.key(name).map { |property| resource.instance_variable_get(property.instance_variable_name) }
        result = http_put("/#{resource.class.storage_name(name)}/#{key}", resource.to_json)
        
        if result["ok"]
          
          key = resource.class.key(name)
          resource.instance_variable_set(key.first.instance_variable_name, result["id"])
          resource.instance_variable_set("@rev", result["rev"])
          true
        else
          false
        end
      end
      
      def read_set(repository, query)
        doc = request do |http|
          http.request(build_javascript_request(query))
        end
        
        populate_set(repository, query.model, query.fields, doc["rows"])
      end

      def view(repository, resource, proc_name)
        properties = resource.properties(repository.name).defaults
        doc = http_get("/#{resource.storage_name(name)}/_view/#{resource.storage_name(name)}/#{proc_name}")
        populate_set(repository, resource, properties, doc["rows"])
      end
      
      def populate_set(repository, resource, properties, docs)
        properties_with_indexes = Hash[*properties.zip((0...properties.length).to_a).flatten]
        set = Collection.new(repository, resource, properties_with_indexes)
        
        docs.each do |doc|
          set.load(properties.map { |property| typecast(property.type, doc["value"][property.field.to_s]) })
        end
        
        set
      end

      def delete_set(repository, query)
        raise NotImplementedError
      end
      
      private
      
      def normalize_uri(uri_or_options)
        uri_or_options = URI.parse(uri_or_options) if String === uri_or_options
        uri_or_options.scheme = "http"
        uri_or_options
      end
      
      def typecast(type, value)
        return value if value.nil?
        case type.to_s
        when "Time"       then Time.at(value)
        when "Date"       then Date.parse(value)
        when "DateTime"   then DateTime.parse(value)
        else value
        end
      end
      
      def build_javascript_request(query)
        
        if query.order.empty?
          key = "null"
        else
          key = query.order.map { |order| "doc.#{order.property.field}" }.join(", ")
          key = "[#{key}]"
        end
        
        request = Net::HTTP::Post.new("/#{query.model.storage_name(name)}/_temp_view")
        request["content-type"] = "text/javascript"
        
        if query.conditions.empty?
          request.body = "function(doc) { map(#{key}, doc); }"
        else
          conditions = query.conditions.map do |operator, property, value|
            condition = "doc.#{property.field}"
            condition << case operator
            when :eql   then " == #{value.to_json}"
            when :not   then " != #{value.to_json}"
            when :gt    then " > #{value.to_json}"
            when :gte   then " >= #{value.to_json}"
            when :lt    then " < #{value.to_json}"
            when :lte   then " <= #{value.to_json}"
            when :like  then like_operator(value)
            end
          end
          request.body = "function(doc) { if (#{conditions.join(" && ")}) { map(#{key}, doc); } }"
        end
        request
      end
      
      def like_operator(value)
        case value
        when Regexp then value = value.source
        when String
          # We'll go ahead and transform this string for SQL compatability
          value = "^#{value}" unless value[0..0] == ("%")
          value = "#{value}$" unless value[-1..-1] == ("%")
          value.gsub!("%", ".*")
          value.gsub!("_", ".")
        end
        return ".match(/#{value}/)"
      end
      
      def http_put(uri, data = nil)
        request { |http| http.put(uri, data) }
      end
      
      def http_post(uri, data)
        request { |http| http.post(uri, data) }
      end
      
      def http_get(uri)
        request { |http| http.get(uri) }
      end
      
      def http_delete(uri)
        request { |http| http.delete(uri) }
      end
      
      def request(parse_result = true, &block)
        res = nil
        Net::HTTP.start(@uri.host, @uri.port) do |http|
          res = yield(http)
        end
        JSON.parse(res.body) if parse_result
      end
      
    end
  end
end