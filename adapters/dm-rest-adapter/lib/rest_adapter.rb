require 'rubygems'
gem 'dm-core', '=0.9.1'
require 'dm-core'
require 'pathname'
require 'net/http'

module DataMapper
  module Adapters
    class RestAdapter < AbstractAdapter
    end
  end
end
