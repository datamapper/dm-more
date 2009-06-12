dir = Pathname(__FILE__).dirname.expand_path / 'dm-aggregates'

require dir / 'adapters' / 'data_objects_adapter'
require dir / 'aggregate_functions'
require dir / 'collection'
require dir / 'core_ext' / 'symbol'
require dir / 'model'
require dir / 'query'
require dir / 'repository'
require dir / 'version'

module DataMapper
  class Repository
    include Aggregates::Repository
  end

  module Model
    include Aggregates::Model
  end

  class Collection
    include Aggregates::Collection
  end

  class Query
    include Aggregates::Query
  end
end
