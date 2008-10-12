require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/couchdb_adapter'

DataMapper.setup(
  :couch,
  Addressable::URI.parse("couchdb://localhost:5984/test_cdb_adapter")
)

#drop/recreate db

@adapter = DataMapper::Repository.adapters[:couch]
@adapter.send(:http_delete, "/#{@adapter.escaped_db_name}")
@adapter.send(:http_put, "/#{@adapter.escaped_db_name}")
