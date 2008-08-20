require 'rubygems'

gem 'dm-core', '=0.9.4'
require 'dm-core'
require 'randexp'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-sweatshop'

require dir / "version"
require dir / "sweatshop"
require dir / "model"