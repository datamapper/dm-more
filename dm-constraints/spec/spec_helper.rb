require 'pathname'
require 'rubygems'

gem 'rspec', '>1.1.12'
require 'spec'

gem 'dm-core', '0.10.0'
require 'dm-core'

require Pathname(__FILE__).dirname.expand_path.parent + 'lib/dm-constraints'

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
