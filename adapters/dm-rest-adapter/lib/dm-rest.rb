$:.push File.expand_path(File.dirname(__FILE__))

require 'dm-core'
require 'extlib'
require 'pathname'
require 'rexml/document'
require 'rubygems'
require 'dm-serializer'
require 'dm-rest/version'
require 'dm-rest/adapter'
require 'dm-rest/connection'
require 'dm-rest/formats'
require 'dm-rest/exceptions'

DataMapper::Adapters::RestAdapter = DataMapperRest::Adapter