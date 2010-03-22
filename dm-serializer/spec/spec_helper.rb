require 'rubygems'

# use local dm-core if running from a typical dev checkout.
lib = File.join('..', '..', 'dm-core', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-core'

# use local dm-validations if running from dm-more directly
lib = File.join('..', 'dm-validations', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-validations'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-serializer'

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

require './spec/lib/serialization_method_shared_spec'

# require fixture resources
Dir.glob('./spec/fixtures/*.rb').each do |fixture_file|
  require fixture_file
end
