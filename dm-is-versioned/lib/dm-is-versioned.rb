require 'pathname'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-is-versioned' / 'is'

require dir / 'versioned'
require dir / 'version'

# Include the plugin in Resource
module DataMapper
  module Model
    include DataMapper::Is::Versioned
  end # module Model
end # module DataMapper
