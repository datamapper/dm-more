require 'pathname'
require 'rubygems'

gem 'rspec', '>=1.1.12'
require 'spec'

gem 'dm-core', '0.10.0'
require 'dm-core'
require 'dm-core/core_ext/symbol'

# TODO: autovalidation hooks are needed badly,
#       otherwise plugin devs will have to abuse
#       alising and load order even further and it kinda makes
#       me sad -- MK
gem 'dm-validations', '0.10.0'
require 'dm-validations'

require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-types'

ENV["SQLITE3_SPEC_URI"]   ||= 'sqlite3::memory:'
ENV["MYSQL_SPEC_URI"]     ||= 'mysql://localhost/dm_core_test'
ENV["POSTGRES_SPEC_URI"]  ||= 'postgres://postgres@localhost/dm_more_test'

# DataMapper::Logger.new(STDOUT, :debug)

def setup_adapter(name, default_uri = nil)
  begin
    DataMapper.setup(name, ENV["#{ENV['ADAPTER'].to_s.upcase}_SPEC_URI"] || default_uri)
    Object.const_set('ADAPTER', ENV['ADAPTER'].to_sym) if name.to_s == ENV['ADAPTER']
    true
  rescue Exception => e
    if name.to_s == ENV['ADAPTER']
      Object.const_set('ADAPTER', nil)
      warn "Could not load do_#{name}: #{e}"
    end
    false
  end
end

ENV['ADAPTER'] ||= 'sqlite3'

setup_adapter(:default)
Dir[Pathname(__FILE__).dirname.to_s + "/fixtures/**/*.rb"].each { |rb| require(rb) }
