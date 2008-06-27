# Needed to import datamapper and other gems
require 'rubygems'
require 'pathname'

# Add all external dependencies for the plugin here
gem 'dm-core', '=0.9.3'
require 'dm-core'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-core'

require dir / 'querizer'
require dir / 'model'
require dir / 'collection'
