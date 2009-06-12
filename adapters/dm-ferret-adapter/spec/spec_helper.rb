require 'pathname'
require 'rubygems'
require 'uuidtools'

gem 'dm-core', '0.10.0'
require 'dm-core'

require Pathname(__FILE__).dirname.parent / 'lib' / 'ferret_adapter'
