require 'pathname'
require 'rubygems'

gem 'dm-core', '0.10.0'
require 'dm-core'

ROOT = Pathname(__FILE__).dirname.parent

require ROOT / 'lib' / 'dm-serializer'

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s

  begin
    DataMapper.setup(name, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
    DataMapper::Repository.adapters[:default] =  DataMapper::Repository.adapters[name]
    DataMapper::Repository.adapters[:alternate] = DataMapper::Repository.adapters[name]
    true
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end

ENV['ADAPTER'] ||= 'sqlite3'

HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')

class SerializerTestHarness
  def test(object, *args)
    deserialize(object.send(method_name, *args))
  end
end

require ROOT / 'spec' / 'lib' / 'serialization_method_shared_spec'

# require fixture resources
Dir[(ROOT / 'spec' / 'fixtures' / '*.rb').to_s].each do |fixture_file|
  require fixture_file
end
