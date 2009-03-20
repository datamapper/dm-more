require 'pathname'
require 'rubygems'

gem 'rspec', '>=1.1.12'
require 'spec'

require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-shorthand'
