require 'pathname'
require 'rubygems'

gem 'dm-core', '0.10.0'
require 'dm-core'

require Pathname(__FILE__).dirname.parent / 'lib' / 'dm-constraints'

ADAPTERS = {}
def load_driver(name, default_uri)
  connection_string = ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri
  begin
    adapter = DataMapper.setup(name.to_sym, connection_string)

    # test the connection if possible
    if adapter.respond_to?(:query)
      adapter.query('SELECT 1')
    end

    ADAPTERS[name] = connection_string
  rescue LoadError => e
    warn "Could not load do_#{name}: #{e}"
    false
  end
end

load_driver(:postgres, 'postgres://postgres@localhost/dm_core_test')
load_driver(:mysql,    'mysql://localhost/dm_core_test')

Spec::Runner.configure do |config|
  config.after :all do
    # global model cleanup
    descendants = DataMapper::Model.descendants.dup.to_a
    while model = descendants.shift
      descendants.concat(model.descendants) if model.respond_to?(:descendants)

      parts         = model.name.split('::')
      constant_name = parts.pop.to_sym
      base          = parts.empty? ? Object : Object.full_const_get(parts.join('::'))

      base.send(:remove_const, constant_name)

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
