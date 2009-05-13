require 'pathname'
require 'rubygems'

gem 'dm-core', '0.10.0'
require 'dm-core'

ROOT = Pathname(__FILE__).dirname.parent.expand_path

require ROOT + 'lib/couchdb_adapter'

COUCHDB_LOCATION = 'couchdb://localhost:5984/test_cdb_adapter'

DataMapper.setup(
  :couch,
  Addressable::URI.parse(COUCHDB_LOCATION)
)

#drop/recreate db

@adapter = DataMapper::Repository.adapters[:couch]
begin
  @adapter.send(:http_delete, "/#{@adapter.escaped_db_name}")
  @adapter.send(:http_put,    "/#{@adapter.escaped_db_name}")
  COUCHDB_AVAILABLE = true
rescue Errno::ECONNREFUSED
  warn "CouchDB could not be contacted at #{COUCHDB_LOCATION}, skipping online dm-couchdb-adapter specs"
  COUCHDB_AVAILABLE = false
end

begin
  gem 'dm-serializer'
  require 'dm-serializer'
  DMSERIAL_AVAILABLE = true
rescue LoadError
  DMSERIAL_AVAILABLE = false
end

Dir[ROOT + 'spec/fixtures/**/*.rb'].each { |rb| require rb }
