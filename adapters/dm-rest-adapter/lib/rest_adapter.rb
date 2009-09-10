require 'rexml/document'

require 'cgi'  # for CGI.escape
require 'addressable/uri'
require 'dm-serializer'

require 'rest_adapter/version'
require 'rest_adapter/adapter'
require 'rest_adapter/connection'
require 'rest_adapter/formats'
require 'rest_adapter/exceptions'

DataMapper::Adapters::RestAdapter = DataMapperRest::Adapter
