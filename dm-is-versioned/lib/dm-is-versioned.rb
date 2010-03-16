require 'dm-core'
require 'dm-is-versioned/is/versioned'

# Include the plugin in Resource
module DataMapper
  module Model
    include DataMapper::Is::Versioned
  end
end
