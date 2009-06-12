require 'pathname'
require 'rubygems'

gem 'dm-core', '0.10.0'
require 'dm-core'

ROOT = Pathname(__FILE__).dirname.parent

require ROOT / 'lib' / 'dm-migrations'
require ROOT / 'lib' / 'migration'
require ROOT / 'lib' / 'migration_runner'
require ROOT / 'lib' / 'sql'

ADAPTERS = []
def load_driver(name, default_uri)
  begin
    DataMapper.setup(name, default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    ADAPTERS << name
    true
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end

#ENV['ADAPTER'] ||= 'sqlite3'

load_driver(:sqlite3,  'sqlite3::memory:')
load_driver(:mysql,    'mysql://localhost/dm_core_test')
load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')
