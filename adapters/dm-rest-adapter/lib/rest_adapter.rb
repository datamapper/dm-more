require 'rubygems'
gem 'dm-core', '=0.9.1'
require 'dm-core'
require 'dm-serializer'
require 'pathname'
require 'net/http'

module DataMapper
  module Adapters
    class RestAdapter < AbstractAdapter
      # Creates a new resource in the specified repository.
      def create(repository, resource)
        result = http_post("/#{resource.class.storage_name}.xml", resource.to_xml)
        #TODO: Check to see if result is HTTP 200, parse id out of response
      end
    protected
      def http_put(uri, data = nil)
        request { |http| http.put(uri, data) }
      end

      def http_post(uri, data)
        request { |http| http.post(uri, data, {"Content-Type", "application/xml"}) }
      end

      def http_get(uri)
        request { |http| http.get(uri) }
      end

      def http_delete(uri)
        request { |http| http.delete(uri) }
      end

      def request(parse_result = true, &block)
        res = nil
        Net::HTTP.start(@uri[:host], @uri[:port].to_i) do |http|
          res = yield(http)
        end
        res
      end    
    end
  end
end