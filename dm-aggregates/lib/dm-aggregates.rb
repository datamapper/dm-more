require 'dm-aggregates/adapters/data_objects_adapter'
require 'dm-aggregates/aggregate_functions'
require 'dm-aggregates/collection'
require 'dm-aggregates/core_ext/symbol'
require 'dm-aggregates/model'
require 'dm-aggregates/query'
require 'dm-aggregates/repository'

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
