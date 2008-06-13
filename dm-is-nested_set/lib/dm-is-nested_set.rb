require 'rubygems'
require 'pathname'

gem 'dm-core', '=0.9.2'
require 'dm-core'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-nested_set' / 'is' / 'nested_set.rb'

module DataMapper
  module Resource
    module ClassMethods
      include DataMapper::Is::NestedSet
    end # module ClassMethods
  end # module Resource
end # module DataMapper
