require 'rubygems'

# use local dm-core if running from a typical dev checkout.
lib = File.join('..', '..', 'dm-core', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-core'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-migrations'
require 'dm-migrations/migration_runner'

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

ENV['ADAPTER'] ||= 'sqlite3'

load_driver(:sqlite3,  'sqlite3::memory:')
load_driver(:mysql,    'mysql://localhost/dm_core_test')
load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')
