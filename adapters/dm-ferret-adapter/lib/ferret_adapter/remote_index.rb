module DataMapper
  module Adapters
    class FerretAdapter::RemoteIndex

      class IndexNotFound < Exception; end
      class SearchError < Exception; end

      attr_accessor :uri

      def initialize(uri)
        @uri = uri

        connect_to_remote_index
      end

      def add(doc)
        @index.write [:add, DRb.uri, doc]
      end

      def delete(query)
        @index.write [:delete, DRb.uri, query]
      end

      def search(query, options)
        tuple = [query, options]
        @index.write [:search, DRb.uri, tuple]
        result = @index.take([:search_result, DRb.uri, tuple, nil]).last
        if result == nil
          raise SearchError.new("An error occurred performing this search. Check the Ferret logs.")
        end
        result
      end

      private

      def connect_to_remote_index
        require "drb"
        require "drb/unix"
        require "rinda/tuplespace"

        DRb.start_service
        tuple_space = DRb::DRbObject.new(nil, "drbunix://#{@uri.path}")

        # This will throw Errno::ENOENT if the socket does not exist.
        tuple_space.respond_to?(:write)

        @index = Rinda::TupleSpaceProxy.new(tuple_space)

      rescue Errno::ENOENT
        raise IndexNotFound.new("Your remote index server is not running.")
      end

    end
  end
end
