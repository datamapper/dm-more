require 'pathname'
require 'rubygems'

gem 'dm-core', '~>0.9.10'
require 'dm-core'

#gem 'dm-adjust', '~>0.9.10'
require 'dm-adjust'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-nested_set' / 'is' / 'nested_set'
