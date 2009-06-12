require 'pathname'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-viewable' / 'is' / 'viewable.rb'

module DataMapper
  module Model
    include DataMapper::Is::Viewable
  end # module Model
end # module DataMapper
