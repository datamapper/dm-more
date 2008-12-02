require 'rubygems'
require 'pathname'

gem 'dm-core', '~>0.9.7'
require 'dm-core'

gem 'dm-validations', '~>0.9.7'
require 'dm-validations'

spec_dir_path = Pathname(__FILE__).dirname.expand_path
require spec_dir_path.parent + 'lib/dm-tags'
require spec_dir_path + 'classes'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!
