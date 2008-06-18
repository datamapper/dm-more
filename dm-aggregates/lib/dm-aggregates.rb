require 'rubygems'

gem 'dm-core', '=0.9.2'
require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-aggregates'

require dir / 'model'
require dir / 'repository'
require dir / 'adapters' / 'data_objects_adapter'
