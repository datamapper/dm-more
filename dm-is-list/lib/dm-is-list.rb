
require 'rubygems'
require 'pathname'

gem 'dm-core', '=0.9.0'
require 'dm-core'

gem 'dm-adjust', '=0.9.2'
require 'dm-adjust'

gem 'dm-aggregates', '=0.9.2'
require 'dm-aggregates'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-list' / 'is' / 'list.rb'
