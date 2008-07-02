require 'rubygems'
gem 'dm-core', '=0.9.3'
require 'base64'
require 'dm-core'
require 'json'
require 'net/http'
require 'pathname'
require 'uri'
require Pathname(__FILE__).dirname + 'couchdb_views'

module DataMapper
  module Resource
    # Converts a Resource to a JSON representation.
    def to_json(dirty = false)
      property_list = self.class.properties.select { |key, value| dirty ? self.dirty_attributes.key?(key) : true }
      inferred_fields = {:type => self.class.name.downcase}
      return (property_list.inject(inferred_fields) do |accumulator, property|
        accumulator[property.field] = instance_variable_get(property.instance_variable_name)
        if property.type == Object
          accumulator[property.field] = Base64.encode64(Marshal.dump(accumulator[property.field]))
        end
        accumulator
      end).to_json
    end
  end
end

module DataMapper
  class Query
    attr_accessor :view
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

      # Creates a new resources in the specified repository.
      def create(resources)
        created = 0
        resources.each do |resource|
          result = http_post("/#{self.escaped_db_name}", resource.to_json(true))
          if result["ok"]
            key = resource.class.key(self.name)
            if key.size == 1
              resource.instance_variable_set(
                key.first.instance_variable_name, result["id"]
              )
            end
            resource.instance_variable_set("@rev", result["rev"])
            created += 1
          end
        end
        created
      end

      # Deletes the resource from the repository.
      def delete(query)
        deleted = 0
        resources = read_many(query)
        resources.each do |resource|
          key = resource.class.key(self.name).map do |property|
            resource.instance_variable_get(property.instance_variable_name)
          end
          result = http_delete(
            "/#{self.escaped_db_name}/#{key}?rev=#{resource.rev}"
          )
          deleted += 1 if result["ok"]
        end
        deleted
      end

      # Commits changes in the resource to the repository.
      def update(attributes, query)
        updated = 0
        resources = read_many(query)
        resources.each do |resource|
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
            updated += 1
          end
        end
        updated
      end

      # Reads in a set from a query.
      def read_many(query)
        doc = request do |http|
          http.request(build_request(query))
        end
        Collection.new(query) do |collection|
          doc['rows'].each do |doc|
            collection.load(
              query.fields.map do |property|
                property.typecast(doc["value"][property.field.to_s])
              end
            )
          end
        end
      end

      def read_one(query)
        doc = request do |http|
          http.request(build_request(query))
        end
        unless doc["rows"].empty?
          data = doc['rows'].first
          query.model.load(
            query.fields.map do |property|
              data["value"][property.field.to_s]
            end,
            query)
        end
      end

      # Reads in a set from a stored view.
      def view(resource, proc_name, options = {})
        query = Query.new(repository, resource)
        query.view = { :name => proc_name }.merge!(options)
        read_many(query)
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

      def build_request(query)
        unless query.view
          ad_hoc_request(query)
        else
          view_request(query)
        end
      end

      def ad_hoc_request(query)
        if query.order.empty?
          key = "null"
        else
          key = (query.order.map do |order|
            "doc.#{order.property.field}"
          end).join(", ")
          key = "[#{key}]"
        end

        options = []
        options << "count=#{query.limit}" if query.limit
        options << "descending=#{query.add_reversed?}" if query.add_reversed?
        options << "skip=#{query.offset}" if query.offset
        options = options.empty? ? nil : "?#{options.join('&')}"

        request = Net::HTTP::Post.new("/#{self.escaped_db_name}/_temp_view#{options}")
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

      def view_request(query)
        options = query.view.dup
        proc_name = options.delete(:name)
        options[:count] = query.limit if query.limit
        options[:descending] = query.add_reversed? if query.add_reversed?
        options[:skip] = query.offset if query.offset

        if options.empty?
          options = ''
        else
          options = "?" + options.to_a.map {|option| "#{option[0]}=#{option[1].to_json}"}.join("&")
        end

        uri = "/#{self.escaped_db_name}/" +
              "_view/" +
              "#{query.model.storage_name(self.name)}/" +
              "#{proc_name}" +
              "#{options}"
        request = Net::HTTP::Get.new(uri)
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

      module Migration
        def create_model_storage(repository, model)
          uri = "/#{self.escaped_db_name}/_design/#{model.storage_name(self.name)}"
          view = Net::HTTP::Put.new(uri)
          view['content-type'] = "text/javascript"
          views = model.views.reject {|key, value| value.nil?}
          view.body = { :views => model.views }.to_json

          request do |http|
            http.request(view)
          end
        end

        def destroy_model_storage(repository, model)
          uri = "/#{self.escaped_db_name}/_design/#{model.storage_name(self.name)}"
          response = http_get(uri)
          unless response['error']
            uri += "?rev=#{response["_rev"]}"
            http_delete(uri)
          end
        end
      end
      include Migration
    end

    # Required naming scheme.
    CouchdbAdapter = CouchDBAdapter
  end
end
