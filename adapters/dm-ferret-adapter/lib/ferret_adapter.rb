require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname + 'ferret_adapter/version'

gem 'dm-core', '~>0.9.7'
require 'dm-core'

gem "ferret"
require "ferret"

module DataMapper
  module Adapters
    class FerretAdapter < AbstractAdapter
      def initialize(name, uri_or_options)
        super
        unless File.extname(@uri.path) == ".sock"
          @index = LocalIndex.new(@uri)
        else
          @index = RemoteIndex.new(@uri)
        end
      end

      def create(resources)
        resources.each do |resource|
          attributes = repository(self.name) do
            attrs = resource.attributes
            attrs.delete_if { |name, value| !resource.class.properties(self.name).has_property?(name) }
            resource.class.new(attrs).attributes
          end

          # Since we don't inspect the models before generating the indices,
          # we'll map the resource's key to the :id column.
          key = resource.class.key.first
          attributes[:id] = attributes.delete(key.name) unless key.name == :id
          attributes[:_type] = resource.class.name

          @index.add attributes
        end
        1
      end

      def delete(query)
        ferret_query = dm_query_to_ferret_query(query)
        @index.delete ferret_query
        1
      end

      # This returns an array of Ferret docs (glorified hashes) which can
      # be used to instantiate objects by doc[:_type] and doc[:_id]
      def read_many(query, limit = query.limit)
        ferret_query = dm_query_to_ferret_query(query)
        @index.search(ferret_query, :limit => (limit || :all))
      end

      def read_one(query)
        read_many(query).first
      end

      # This returns a hash of the resource constant and the ids returned for it
      # from the search.
      #   { Story => ["1", "2"], Image => ["2"] }
      def search(query, limit)
        results = Hash.new { |h, k| h[k] = [] }
        read_many(query, limit).each do |doc|
          results[Object.const_get(doc[:_type])] << doc[:id]
        end
        results
      end

      private

      def dm_query_to_ferret_query(query)
        # If we already have a ferret query, do nothing
        return query if query.is_a?(String)

        ferret = []

        # We scope the query by the _type field to the query's model.
        ferret << "+_type:\"#{query.model.name}\""

        if query.conditions.empty?
          ferret << "*"
        else
          query.conditions.each do |operator, property, value|
            # We use property.field here, so that you can declare composite
            # fields:
            #     property :content, String, :field => "title|description"
            name = property.field

            # Since DM's query syntax does not support OR's, we prefix
            # each condition with ferret's operator of +.
            ferret << case operator
            when :eql, :like  then "+#{name}:\"#{value}\""
            when :not         then "-#{name}:\"#{value}\""
            when :lt          then "+#{name}: < #{value}"
            when :gt          then "+#{name}: > #{value}"
            when :lte         then "+#{name}: <= #{value}"
            when :gte         then "+#{name}: >= #{value}"
            end
          end
        end
        ferret.join(" ")
      end

    end
  end
end

require Pathname(__FILE__).dirname + "ferret_adapter/local_index"
require Pathname(__FILE__).dirname + "ferret_adapter/remote_index"
require Pathname(__FILE__).dirname + "ferret_adapter/repository_ext"
