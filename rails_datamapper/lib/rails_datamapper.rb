gem 'dm-core', '0.9.12'
require 'pathname'
require 'dm-core'
require Pathname(__FILE__).dirname.expand_path / 'rails_datamapper/rails_datamapper'
create_connection()
