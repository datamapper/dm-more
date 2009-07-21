# TODO: autovalidation hooks are needed badly,
#       otherwise plugin devs will have to abuse
#       alising and load order even further and it kinda makes
#       me sad -- MK

require 'pathname'
require 'rubygems'

gem 'dm-core', '0.10.0'
require 'dm-core'

ROOT = Pathname(__FILE__).dirname.parent

# use local dm-validations if running from dm-more directly
lib = ROOT.parent / 'dm-validations' / 'lib'
$LOAD_PATH.unshift(lib) if lib.directory?
require 'dm-validations'

require ROOT / 'lib' / 'dm-types'

ENV['SQLITE3_SPEC_URI']   ||= 'sqlite3::memory:'
ENV['MYSQL_SPEC_URI']     ||= 'mysql://localhost/dm_core_test'
ENV['POSTGRES_SPEC_URI']  ||= 'postgres://postgres@localhost/dm_more_test'

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

DEPENDENCIES = {
  'bcrypt'    => 'bcrypt-ruby',
  'fastercsv' => 'fastercsv',
  'json'      => 'json',
  'stringex'  => 'stringex',
  'uuidtools' => 'uuidtools',
}

def try_spec
  begin
    yield
  rescue NameError
    # do nothing
  rescue LoadError => error
    raise error unless lib = error.message.match(/\Ano such file to load -- (.+)\z/)[1]

    gem_location = DEPENDENCIES[lib] || raise("Unknown lib #{lib}")

    warn "[WARNING] Skipping specs using #{lib}, please do: gem install #{gem_location}"
  end
end
