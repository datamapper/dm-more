require 'rubygems'

gem 'dm-core', '~>0.9.10'
require 'dm-core'

gem 'randexp', '~>0.1.4'
require 'randexp'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-sweatshop'

require dir / 'version'
require dir / 'sweatshop'
require dir / 'model'
require dir / 'unique'
