require 'pathname'
require 'rubygems'

gem 'dm-core', '0.10.0'
require 'dm-core'

ROOT = Pathname(__FILE__).dirname.parent

# use local dm-validations if running from dm-more directly
lib = ROOT.parent / 'dm-validations' / 'lib'
$LOAD_PATH.unshift(lib) if lib.directory?
require 'dm-validations'

require ROOT / 'lib' / 'dm-sweatshop'

DataMapper.setup(:default, 'sqlite3::memory:')

begin
  Randexp::Dictionary.load_dictionary
rescue RuntimeError
  warn '[WARNING] Neither /usr/share/dict/words or /usr/dict/words found, skipping dm-sweatshop specs'
  exit
end
