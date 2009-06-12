require 'pathname'
require 'dm-adjust'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-is-nested_set' / 'is'

require dir / 'nested_set'
require dir / 'version'
