require 'pathname'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-example' / 'is' / 'example.rb'

module DataMapper
  module Model
    include DataMapper::Is::Example
  end # module Model
end # module DataMapper
