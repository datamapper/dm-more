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
          key = resource.class.key(self.name).map do |property|
            resource.instance_variable_get(property.instance_variable_name)
          end
          if key.compact.empty?
            result = http_post("/#{self.escaped_db_name}", resource.to_json(true))
          else
            result = http_put("/#{self.escaped_db_name}/#{key}", resource.to_json(true))
          end
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
        if doc['rows']
          Collection.new(query) do |collection|
            doc['rows'].each do |doc|
              collection.load(
                query.fields.map do |property|
                  property.typecast(doc["value"][property.field.to_s])
                end
              )
            end
          end
        else
          []
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

        request = Net::HTTP::Post.new("/#{self.escaped_db_name}/_temp_view#{query_string(query)}")
        request["Content-Type"] = "application/json"

        if query.conditions.empty?
          request.body =
%Q({"map":
  "function(doc) {
  if (doc.type == '#{query.model.name.downcase}') {
    emit(#{key}, doc);
    }
  }"
}
)
        else
          conditions = query.conditions.map do |operator, property, value|
            json_value = value.to_json.gsub("\"", "'")
            condition = "doc.#{property.field}"
            condition << case operator
            when :eql   then " == #{json_value}"
            when :not   then " != #{json_value}"
            when :gt    then " > #{json_value}"
            when :gte   then " >= #{json_value}"
            when :lt    then " < #{json_value}"
            when :lte   then " <= #{json_value}"
            when :like  then like_operator(value)
            end
          end
          request.body =
%Q({"map":
  "function(doc) {
    if (doc.type == '#{query.model.name.downcase}' && #{conditions.join(" && ")}) { 
      emit(#{key}, doc);
    }
  }"
}
)
        end
        request
      end

      def view_request(query)
        uri = "/#{self.escaped_db_name}/" +
              "_view/" +
              "#{query.model.storage_name(self.name)}/" +
              "#{query.view}" +
              "#{query_string(query)}"
        request = Net::HTTP::Get.new(uri)
      end
      
      def query_string(query)
        query_string = []
        if query.view_options
          query_string +=
            query.view_options.map do |key, value|
              if [:endkey, :key, :startkey].include? key
                URI.escape(%Q(#{key}="#{value}"))
              else
                URI.escape("#{key}=#{value}")
              end
            end
        end
        query_string << "count=#{query.limit}" if query.limit
        query_string << "descending=#{query.add_reversed?}" if query.add_reversed?
        query_string << "skip=#{query.offset}" if query.offset
        query_string.empty? ? nil : "?#{query_string.join('&')}"
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
          view.body = { :views => views }.to_json

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
