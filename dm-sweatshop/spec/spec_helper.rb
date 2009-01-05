require 'pathname'
require 'rubygems'

gem 'dm-core', '~>0.9.8'
require 'dm-core'

ROOT = Pathname(__FILE__).dirname.parent.expand_path

# use local dm-validations if running from dm-more directly
lib = ROOT.parent.join('dm-validations', 'lib').expand_path
$LOAD_PATH.unshift(lib) if lib.directory?
require 'dm-validations'

require ROOT + 'lib/dm-sweatshop'

DataMapper.setup(:default, 'sqlite3::memory:')
