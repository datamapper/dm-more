
require 'rubygems'
require 'pathname'

gem 'dm-core', '=0.9.2'
require 'dm-core'

gem 'dm-adjust', '=0.9.2'
require 'dm-adjust'

gem 'dm-aggregates', '=0.9.2'
require 'dm-aggregates'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-list' / 'is' / 'list.rb'

module DataMapper
  module Resource
    module ClassMethods
      include DataMapper::Is::List
    end # module ClassMethods
  end # module Resource
end # module DataMapper
