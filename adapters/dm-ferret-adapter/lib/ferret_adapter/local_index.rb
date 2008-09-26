module DataMapper
  module Adapters
    class FerretAdapter::LocalIndex

      attr_accessor :uri

      def initialize(uri)
        @uri = uri
        @options = { :path => @uri.path, :key => [:id, :_type] }
        create_or_initialize_index
      end

      def add(doc)
        @index << doc
      end

      def delete(query)
        @index.query_delete(query)
      end

      def search(query, options = {})
        @index.search(query, options).hits.collect { |hit, score| @index[hit.doc] }
      end

      def [](id)
        @index[id]
      end

      private

      def create_or_initialize_index
        unless File.exists?(@uri.path + "segments")
          field_infos = ::Ferret::Index::FieldInfos.new(:store => :no)
          field_infos.add_field(:id, :index => :untokenized, :term_vector => :no, :store => :yes)
          field_infos.add_field(:_type, :index => :untokenized, :term_vector => :no, :store => :yes)
          @index = ::Ferret::Index::Index.new( @options.merge(:field_infos => field_infos) )
        else
          @index = ::Ferret::Index::Index.new( @options )
        end
      end
    end
  end
end
