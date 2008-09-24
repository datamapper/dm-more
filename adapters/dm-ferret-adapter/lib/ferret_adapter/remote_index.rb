module DataMapper
  module Adapters
    class FerretAdapter::RemoteIndex

      attr_accessor :uri

      def initialize(uri)
        @uri = uri

        require "rinda/ring"
        DRb.start_service

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
          raise "An error occurred performing this search. Check the Ferret logs."
        end
        result
      end

      private

      def connect_to_remote_index
        @server = Rinda::RingFinger.primary
        services = @server.read_all [:name, nil, nil, nil]

        if services.detect { |service| service[3] == @uri.path }
          tuple_space = @server.read([:name, :TupleSpace, nil, @uri.path])[2]
          @index = Rinda::TupleSpaceProxy.new tuple_space
        else
          raise
        end
      rescue
        raise "Your remote index server is not running."
      end

    end
  end
end