require 'rubygems'
require 'pathname'
require 'fakeweb'

# use local dm-core if running from a typical dev checkout.
lib = File.join('..', '..', '..', 'dm-core', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)

# use local dm-validations if running from a typical dev checkout.
lib = File.join('..', '..', 'dm-validations', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)
require 'dm-validations'

# use local dm-serializer if running from a typical dev checkout.
lib = File.join('..', '..', 'dm-serializer', 'lib')
$LOAD_PATH.unshift(lib) if File.directory?(lib)

# Support running specs with 'rake spec' and 'spec'
$LOAD_PATH.unshift('lib') unless $LOAD_PATH.include?('lib')

require 'rest_adapter'

ROOT = Pathname(__FILE__).dirname.parent

DataMapper.setup(:default, 'rest://admin:secret@localhost:4000/?format=xml')

Dir[ROOT / 'spec' / 'fixtures' / '**' / '*.rb'].each { |rb| require rb }

FakeWeb.allow_net_connect = false
