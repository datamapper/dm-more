require 'rubygems'
gem 'dm-core', '=0.9.1'
require 'dm-core'
require 'pathname'
require 'net/http'

module DataMapper
  module Adapters
    class RestAdapter < AbstractAdapter
      # Creates a new resource in the specified repository.
      def create(repository, resource)
        result = http_post("/#{resource.storage_name}", resource.to_http_post_data)
        #TODO: Check to see if result is HTTP 200, convert XML data to Array of instances of DM Resource 
      end
    end
  end
end