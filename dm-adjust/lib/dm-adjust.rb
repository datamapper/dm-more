require 'rubygems'

gem 'dm-core', '=0.9.2'
require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-adjust'

require dir / 'collection'
require dir / 'model'
require dir / 'repository'
require dir / 'adapters' / 'data_objects_adapter'
