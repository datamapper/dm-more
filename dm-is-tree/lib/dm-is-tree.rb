require 'rubygems'
require 'pathname'

gem 'dm-core', '~>0.9.9'
require 'dm-core'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-tree' / 'is' / 'tree.rb'
