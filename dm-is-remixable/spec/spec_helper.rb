require 'rubygems'

# use local dm-core if running from a typical dev checkout.
lib = File.join('..', '..', 'dm-core', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-core'

# use local dm-types if running from a typical dev checkout.
lib = File.join('..', 'dm-types', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-types'

# use local dm-validations if running from a typical dev checkout.
lib = File.join('..', 'dm-validations', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-validations'

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'dm-is-remixable'

require 'data/addressable'
require 'data/article'
require 'data/billable'
require 'data/bot'
require 'data/commentable'
require 'data/image'
require 'data/rating'
require 'data/tag'
require 'data/taggable'
require 'data/topic'
require 'data/user'
require 'data/viewable'

def load_driver(name, default_uri)
  return false if ENV['ADAPTER'] != name.to_s

  begin
    DataMapper.setup(:default, ENV["#{name.to_s.upcase}_SPEC_URI"] || default_uri)
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
