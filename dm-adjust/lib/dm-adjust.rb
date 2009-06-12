require 'pathname'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-adjust'

require dir / 'adapters' / 'data_objects_adapter'
require dir / 'collection'
require dir / 'query' / 'conditions' / 'comparison'
require dir / 'model'
require dir / 'repository'
require dir / 'resource'
require dir / 'version'
