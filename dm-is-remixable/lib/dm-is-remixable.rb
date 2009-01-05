require 'pathname'
require 'rubygems'

gem 'dm-core', '~>0.9.10'
require 'dm-core'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-remixable' / 'is' / 'remixable'

module DataMapper
  module Resource
    module ClassMethods
      include DataMapper::Is::Remixable
    end # module ClassMethods
  end # module Resource
end # module DataMapper
