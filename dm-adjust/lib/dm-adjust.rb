require 'rubygems'
require 'pathname'

require Pathname(__FILE__).dirname + 'dm-adjust/version'

gem 'dm-core', DataMapper::More::Adjust::VERSION
require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-adjust'

require dir / 'collection'
require dir / 'model'
require dir / 'repository'
require dir / 'adapters' / 'data_objects_adapter'
