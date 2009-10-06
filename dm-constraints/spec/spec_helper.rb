require 'rubygems'

# use local dm-core if running from a typical dev checkout.
lib = File.join('..', '..', 'dm-core', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-core'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-constraints'

ADAPTERS = {}
def load_driver(name, default_uri)
  connection_string = ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri
  begin
    adapter = DataMapper.setup(name.to_sym, connection_string)

    # test the connection if possible
    if adapter.respond_to?(:query)
      adapter.select('SELECT 1')
    end

    ADAPTERS[name] = connection_string
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end


HAS_SQLITE3  = load_driver(:sqlite3,  'sqlite3::memory:')
HAS_MYSQL    = load_driver(:mysql,    'mysql://localhost/dm_core_test')
HAS_POSTGRES = load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')


Spec::Runner.configure do |config|
  config.after :all do
    # global model cleanup
    descendants = DataMapper::Model.descendants.to_a
    while model = descendants.shift
      descendants.concat(model.descendants.to_a - [ model ])

      parts         = model.name.split('::')
      constant_name = parts.pop.to_sym
      base          = parts.empty? ? Object : Object.full_const_get(parts.join('::'))

      if base.const_defined?(constant_name)
        base.send(:remove_const, constant_name)
      end

      DataMapper::Model.descendants.delete(model)
    end
  end

  config.before do
    DataMapper.auto_migrate!
  end

  config.after do
    DataMapper.send(:auto_migrate_down!, @repository.name)
  end
end
