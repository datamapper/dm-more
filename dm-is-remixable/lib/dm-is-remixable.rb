require 'pathname'
require Pathname(__FILE__).dirname.expand_path / 'dm-is-remixable' / 'is' / 'remixable'

module DataMapper
  module Model
    include DataMapper::Is::Remixable
  end # module Model
end # module DataMapper
