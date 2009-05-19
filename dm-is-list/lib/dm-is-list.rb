require 'pathname'
require 'dm-core'
require 'dm-adjust'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-list' / 'is' / 'list'

DataMapper::Model.append_extensions DataMapper::Is::List
