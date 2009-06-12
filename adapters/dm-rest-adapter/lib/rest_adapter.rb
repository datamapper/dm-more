require 'pathname'
require 'rexml/document'

require 'cgi'  # for CGI.escape
require 'extlib'
require 'addressable/uri'
require 'dm-serializer'

dir = Pathname(__FILE__).dirname.expand_path / 'rest_adapter'

require dir / 'version'
require dir / 'adapter'
require dir / 'connection'
require dir / 'formats'
require dir / 'exceptions'

DataMapper::Adapters::RestAdapter = DataMapperRest::Adapter
