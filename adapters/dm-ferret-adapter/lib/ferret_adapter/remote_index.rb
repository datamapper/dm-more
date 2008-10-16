module DataMapper
  module Adapters
    class FerretAdapter::RemoteIndex

      class IndexNotFound < Exception; end
      class SearchError < Exception; end

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
          raise SearchError.new("An error occurred performing this search. Check the Ferret logs.")
        end
        result
      end

      private

      def connect_to_remote_index
        if @uri.host == "localhost"
          # Rinda::RingFinger.new(nil) uses a broadcast list of just ["localhost"], and will
          # find only local Rinda broadcasts.
          finger = Rinda::RingFinger.new(nil)

          @service = @uri.path[1..-1]
        else
          # Rinda::RingFinger.new defaults to a broadcast list of ["<broadcast>", "localhost"],
          # and thus will find any public or local Rinda broadcast.
          finger = Rinda::RingFinger.new

          @service = @uri.host
        end

        finger.each do |server|
          services = server.read_all [:name, nil, nil, nil]

          if services.detect { |service| service[3] == @service }
            tuple_space = server.read([:name, :TupleSpace, nil, @service])[2]
            break @index = Rinda::TupleSpaceProxy.new(tuple_space)
          end
        end

        raise IndexNotFound.new("Your remote index server is not running.") unless @index
      end

    end
  end
end
