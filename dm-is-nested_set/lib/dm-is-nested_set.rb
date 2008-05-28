require 'rubygems'
require 'pathname'

gem 'dm-core', '=0.9.1'
require 'data_mapper'
require 'dm-aggregates'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-nested_set' / 'is' / 'nested_set.rb'
