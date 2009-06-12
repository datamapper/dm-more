require 'pathname'
require 'rubygems'
require 'fakeweb'

gem 'dm-core', '0.10.0'
require 'dm-core'

ROOT = Pathname(__FILE__).dirname.parent

# use local dm-serializer if running from dm-more directly
lib = ROOT.parent.parent / 'dm-serializer' / 'lib'
$LOAD_PATH.unshift(lib) if lib.directory?

require ROOT / 'lib' / 'rest_adapter'

DataMapper.setup(:default, 'rest://admin:secret@localhost:4000/?format=xml')

Dir[ROOT / 'spec' / 'fixtures' / '**' / '*.rb'].each { |rb| require rb }

FakeWeb.allow_net_connect = false
