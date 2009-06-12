require 'pathname'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-querizer'

require dir / 'querizer'
require dir / 'model'
require dir / 'collection'
