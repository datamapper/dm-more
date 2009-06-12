require 'pathname'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-searchable' / 'is' / 'searchable.rb'

module DataMapper
  module Model
    include DataMapper::Is::Searchable
  end # module Model
end # module DataMapper
