require 'pathname'
require 'rubygems'

gem 'dm-core', '0.10.0'
require 'dm-core'

require 'spec'
require 'uuidtools'

require Pathname(__FILE__).dirname.parent + 'lib/ferret_adapter'
