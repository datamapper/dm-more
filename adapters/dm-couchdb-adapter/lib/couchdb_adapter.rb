require 'rubygems'
gem 'dm-core', '=0.9.1'
require 'dm-core'
require 'pathname'
require 'net/http'
require 'json'
require 'uri'
require Pathname(__FILE__).dirname + 'couchdb_views'

class Time
  # Converts a Time object to a JSON representation.
  def to_json(*a)
    self.to_i.to_json(*a)
  end
end

module DataMapper
  module Resource
    # Converts a Resource to a JSON representation.
    def to_json(dirty = false)
      property_list = (dirty ? self.dirty_attributes : self.class.properties)
      inferred_fields = {:type => self.class.name.downcase}
      return (property_list.inject(inferred_fields) do |accumulator, property|
        accumulator[property.field] =
          unless [Date, DateTime].include? property.type
            instance_variable_get(property.instance_variable_name)
          else
            instance_variable_get(property.instance_variable_name).to_s
          end
        accumulator
      end).to_json
    end
  end
end

module DataMapper
  module Adapters
    class CouchDBAdapter < AbstractAdapter
      # Returns the name of the CouchDB database.
      #
      # Raises an exception if the CouchDB database name is invalid.
      def db_name
        result = @uri.path.scan(/^\/?([-_+%()$a-z0-9]+?)\/?$/).flatten[0]
        if result != nil
          return Addressable::URI.unencode_segment(result)
        else
          raise StandardError, "Invalid database path: '#{@uri.path}'"
        end
      end

      # Returns the name of the CouchDB database after being escaped.
      def escaped_db_name
        return Addressable::URI.encode_segment(
          self.db_name, Addressable::URI::CharacterClasses::UNRESERVED)
      end

      # Creates a new resource in the specified repository.
      def create(repository, resource)
        result = http_post("/#{self.escaped_db_name}", resource.to_json(true))
        if result["ok"]
          key = resource.class.key(self.name)
          if key.size == 1
            resource.instance_variable_set(
              key.first.instance_variable_name, result["id"]
            )
          end
          resource.instance_variable_set("@rev", result["rev"])
          true
        else
          false
        end
      end

      # Deletes the resource from the repository.
      def delete(repository, resource)
        key = resource.class.key(self.name).map do |property|
          resource.instance_variable_get(property.instance_variable_name)
        end
        result = http_delete(
          "/#{self.escaped_db_name}/#{key}?rev=#{resource.rev}"
        )
        return result["ok"]
      end

      # Commits changes in the resource to the repository.
      def update(repository, resource)
        key = resource.class.key(self.name).map do |property|
          resource.instance_variable_get(property.instance_variable_name)
        end
        result = http_put("/#{self.escaped_db_name}/#{key}", resource.to_json)

        if result["ok"]
          key = resource.class.key(self.name)
          resource.instance_variable_set(
            key.first.instance_variable_name, result["id"])
          resource.instance_variable_set(
            "@rev", result["rev"])
          true
        else
          false
        end
      end

      # Reads in a set from a query.
      def read_set(repository, query)
        doc = request do |http|
          http.request(build_javascript_request(query))
        end
        populate_set(repository, query, doc["rows"])
      end

      # Reads in a set from a stored view.
      def view(repository, resource, proc_name, options = {})
        if options.empty?
          options = ''
        else
          options = "?" + options.to_a.map {|option| "#{option[0]}=#{option[1].to_json}"}.join("&")
        end
        options = URI.encode(options)
        doc = http_get(
          "/#{self.escaped_db_name}/_view" +
          "/#{resource.storage_name(self.name)}/#{proc_name}" +
          "#{options}"
        )
        query = Query.new(repository, resource)
        populate_set(repository, query, doc["rows"])
      end

      # Populates a set with data from the supplied docs.
      def populate_set(repository, query, docs)
        resource, properties = query.model, query.fields
        properties_with_indexes =
          Hash[*properties.zip((0...properties.length).to_a).flatten]
        set = Collection.new(query)

        docs.each do |doc|
          set.load(
            properties.map do |property|
              typecast(property.type, doc["value"][property.field.to_s])
            end
          )
        end

        set
      end

      def delete_set(repository, query)
        raise NotImplementedError
      end

    protected
      # Converts the URI's scheme into a parsed HTTP identifier.
      def normalize_uri(uri_or_options)
        if String === uri_or_options
          uri_or_options = Addressable::URI.parse(uri_or_options)
        end
        if Addressable::URI === uri_or_options
          return uri_or_options.normalize
        end

        user = uri_or_options.delete(:username)
        password = uri_or_options.delete(:password)
        host = (uri_or_options.delete(:host) || "")
        port = uri_or_options.delete(:port)
        database = uri_or_options.delete(:database)
        query = uri_or_options.to_a.map { |pair| pair.join('=') }.join('&')
        query = nil if query == ""

        return Addressable::URI.new(
          "http", user, password, host, port, database, query, nil
        )
      end

      def typecast(type, value)
        return value if value.nil?
        case type.to_s
        when "Time"       then Time.at(value.to_i)
        when "Date"       then Date.parse(value)
        when "DateTime"   then DateTime.parse(value)
        else value
        end
      end

      def build_javascript_request(query)
        if query.order.empty?
          key = "null"
        else
          key = (query.order.map do |order|
            "doc.#{order.property.field}"
          end).join(", ")
          key = "[#{key}]"
        end

        request = Net::HTTP::Post.new("/#{self.escaped_db_name}/_temp_view")
        request["Content-Type"] = "text/javascript"

        if query.conditions.empty?
          request.body =
            "function(doc) {\n" +
            "  if (doc.type == '#{query.model.name.downcase}') {\n" +
            "    map(#{key}, doc);\n" +
            "  }\n" +
            "}\n"
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
          body = <<-JS
            function(doc) {
              if (doc.type == '#{query.model.name.downcase}') {
                if (#{conditions.join(" && ")}) {
                  map(#{key}, doc);
                }
              }
            }
          JS
          space = body.split("\n")[0].to_s[/^(\s+)/, 0]
          request.body = body.gsub(/^#{space}/, '')
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

    # Required naming scheme.
    CouchdbAdapter = CouchDBAdapter
  end
end
