require 'rubygems'
require 'pathname'
require Pathname(__FILE__).dirname + 'ferret_adapter/version'
gem 'dm-core', DataMapper::More::FerretAdapter::VERSION
require 'dm-core'
require "ferret"

module DataMapper
  module Adapters
    class FerretAdapter < AbstractAdapter
      def initialize(name, uri_or_options)
        super
        options = { :path => @uri.path, :key => [:id, :_type] }
        unless File.exists?(@uri.path + "segments")
          field_infos = Ferret::Index::FieldInfos.new(:store => :no)
          field_infos.add_field(:id, :index => :untokenized, :term_vector => :no, :store => :yes)
          field_infos.add_field(:_type, :index => :untokenized, :store => :yes)
          @index = Ferret::Index::Index.new( options.merge(:field_infos => field_infos) )
        else
          @index = Ferret::Index::Index.new( options )
        end
      end

      def create(resources)
        resources.each do |resource|
          attributes = resource.attributes.merge(:_type => resource.class.name)
          @index << attributes
        end
        1
      end

      def delete(query)
        ferret_query = dm_query_to_ferret_query(query)
        @index.query_delete(ferret_query)
        1
      end

      # This returns an array of Ferret docs (glorified hashes) which can
      # be used to instantiate objects by doc[:_type] and doc[:_id]
      def read_many(query, limit = query.limit)
        ferret_query = dm_query_to_ferret_query(query)
        @index.search(ferret_query, :limit => (limit || :all)).hits.collect { |hit, score| @index[hit.doc] }
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
            # Since DM's query syntax does not support OR's, we prefix
            # each condition with ferret's operator of +.
            name = property.name
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

module DataMapper
  class Repository
    # This accepts a ferret query string and an optional limit argument
    # which defaults to all. This is the proper way to perform searches more
    # complicated than DM's query syntax can handle (such as OR searches).
    # 
    # See DataMapper::Adapters::FerretAdapter#search for information on
    # the return value.
    def search(query, limit = :all)
      adapter.search(query, limit)
    end
  end
end