require 'rubygems'
gem 'rspec', '>=1.1.3'
require 'spec'
require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-migrations'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/migration_runner'

ADAPTERS = []
def load_driver(name, default_uri)

  lib = "do_#{name}"
  begin
    gem lib, '~>0.9.7'
    require lib
    DataMapper.setup(name, default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    ADAPTERS << name
    true
  rescue Gem::LoadError => e
    warn "dm-migrations specs will not be run against #{name} - Could not load #{lib}: #{e}."
    false
  end
end

#ENV['ADAPTER'] ||= 'sqlite3'

load_driver(:sqlite3,  'sqlite3::memory:')
load_driver(:mysql,    'mysql://localhost/dm_core_test')
load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')
