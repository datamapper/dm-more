require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-aggregates'

require dir / 'aggregate_functions'
require dir / 'model'
require dir / 'repository'
require dir / 'collection'

require dir / 'adapters' / 'data_objects_adapter'
require dir / 'core_ext' / 'symbol'
require dir / 'version'
