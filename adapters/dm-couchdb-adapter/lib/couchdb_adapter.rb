require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname + 'couchdb_adapter/version'
gem 'dm-core', DataMapper::More::CouchDBAdapter::VERSION
require 'dm-core'
require 'json'
require 'ostruct'
require 'net/http'
require 'uri'
require Pathname(__FILE__).dirname + 'couchdb_adapter/attachments'
require Pathname(__FILE__).dirname + 'couchdb_adapter/json_object'
require Pathname(__FILE__).dirname + 'couchdb_adapter/view'

module DataMapper
  module Resource
    # Converts a Resource to a JSON representation.
    def to_json(dirty = false)
      property_list = self.class.properties.select { |key, value| dirty ? self.dirty_attributes.key?(key) : true }
      data = {}
      for property in property_list do
        raise PersistenceError, '+couchdb_type+ is a reserved column name', caller if property.field == 'couchdb_type'
        data[property.field] =
          if property.type.respond_to?(:dump)
            property.type.dump(property.get!(self), property)
          else
            property.get!(self)
          end
      end
      data.delete(:_attachments) if data[:_attachments].nil? || data[:_attachments].empty?
      data[:couchdb_type] = self.class.storage_name(repository.name)
      return data.to_json
    end
  end
end

module DataMapper
  module Adapters
    class CouchDBAdapter < AbstractAdapter
      def initialize(name, uri_or_options)
        super(name, uri_or_options)
        @resource_naming_convention = NamingConventions::Resource::Underscored
      end

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
        if query.view && query.model.views[query.view.to_sym].has_key?('reduce')
          doc['rows'].map {|row| OpenStruct.new(row)}
        else
          collection =
          if doc['rows'] && !doc['rows'].empty?
            Collection.new(query) do |collection|
              doc['rows'].each do |doc|
                data = doc["value"]
                  collection.load(
                    query.fields.map do |property|
                      property.typecast(data[property.field.to_s])
                    end
                  )
              end
            end
          elsif doc['couchdb_type'] && doc['couchdb_type'] == query.model.storage_name(repository.name)
            data = doc
            Collection.new(query) do |collection|
              collection.load(
                query.fields.map do |property|
                  property.typecast(data[property.field.to_s])
                end
              )
            end
          else
            Collection.new(query) { [] }
          end
          collection.total_rows = doc && doc['total_rows'] || 0
          collection
        end
      end

      def read_one(query)
        doc = request do |http|
          http.request(build_request(query))
        end
        if doc['rows'] && !doc['rows'].empty?
          data = doc['rows'].first['value']
        elsif !doc['rows']
          data = doc if doc['couchdb_type'] && doc['couchdb_type'] == query.model.storage_name(repository.name)
        end
        if data
          query.model.load(
            query.fields.map do |property|
              property.typecast(data[property.field.to_s])
            end,
            query
          )
        end
      end

    protected
      def normalize_uri(uri_or_options)
        if uri_or_options.kind_of?(String) || uri_or_options.kind_of?(Addressable::URI)
          uri_or_options = DataObjects::URI.parse(uri_or_options)
        end

        if uri_or_options.kind_of?(DataObjects::URI)
          return uri_or_options
        end

        adapter  = uri_or_options.delete(:adapter).to_s
        user     = uri_or_options.delete(:username)
        password = uri_or_options.delete(:password)
        host     = uri_or_options.delete(:host)
        port     = uri_or_options.delete(:port)
        database = uri_or_options.delete(:database)
        query    = uri_or_options.to_a.map { |pair| pair * '=' } * '&'
        query    = nil if query == ''

        return DataObjects::URI.parse(Addressable::URI.new(adapter, user, password, host, port, database, query, nil))
      end

      def build_request(query)
        if query.view
          view_request(query)
        elsif query.conditions.length == 1 &&
              query.conditions.first[0] == :eql &&
              query.conditions.first[1].key? &&
              query.conditions.first[2] &&
              query.conditions.first[2].length == 1
              !query.conditions.first[2].is_a?(String)
          get_request(query)
        else
          ad_hoc_request(query)
        end
      end

      def view_request(query)
        uri = "/#{self.escaped_db_name}/" +
              "_view/" +
              "#{query.model.storage_name(self.name)}/" +
              "#{query.view}" +
              "#{query_string(query)}"
        request = Net::HTTP::Get.new(uri)
      end

      def get_request(query)
        uri = "/#{self.escaped_db_name}/#{query.conditions.first[2]}"
        request = Net::HTTP::Get.new(uri)
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
  if (doc.couchdb_type == '#{query.model.storage_name(self.name)}') {
    emit(#{key}, doc);
    }
  }"
}
)
        else
          conditions = query.conditions.map do |operator, property, value|
            if operator == :eql && value.is_a?(Array)
              value.map do |sub_value|
                json_sub_value = sub_value.to_json.gsub("\"", "'")
                "doc.#{property.field} == #{json_sub_value}"
              end.join(" || ")
            else
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
          end
          request.body =
%Q({"map":
  "function(doc) {
    if (doc.couchdb_type == '#{query.model.storage_name(self.name)}' && #{conditions.join(" && ")}) {
      emit(#{key}, doc);
    }
  }"
}
)
        end
        request
      end

      def query_string(query)
        query_string = []
        if query.view_options
          query_string +=
            query.view_options.map do |key, value|
              if [:endkey, :key, :startkey].include? key
                URI.escape(%Q(#{key}=#{value.to_json}))
              else
                URI.escape("#{key}=#{value}")
              end
            end
        end
        query_string << "count=#{query.limit}" if query.limit
        query_string << "descending=#{query.add_reversed?}" if query.add_reversed?
        query_string << "skip=#{query.offset}" if query.offset != 0
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
