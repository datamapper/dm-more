require 'dm-core'
require 'dm-is-searchable/is/searchable'

module DataMapper
  module Model
    include DataMapper::Is::Searchable
  end
end
