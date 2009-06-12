require 'pathname'

gem 'dm-core', '0.10.0'
require 'dm-core'

require Pathname(__FILE__).dirname.expand_path / 'rails_datamapper/rails_datamapper'

create_connection()
