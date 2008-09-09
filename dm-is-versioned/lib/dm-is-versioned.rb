require 'rubygems'
require 'pathname'

gem 'dm-core', '=0.9.6'
require 'dm-core'

require Pathname(__FILE__).dirname.expand_path / 'dm-is-versioned' / 'is' / 'versioned.rb'

# Include the plugin in Resource
module DataMapper
  module Resource
    module ClassMethods
      include DataMapper::Is::Versioned
    end # module ClassMethods
  end # module Resource
end # module DataMapper
