require 'dm-is-versioned/is/versioned'
require 'dm-is-versioned/is/version'

# Include the plugin in Resource
module DataMapper
  module Model
    include DataMapper::Is::Versioned
  end
end
