
# for development, try loading ../dm-core first
$:.unshift(File.join(File.dirname(__FILE__), '..', '..', 'dm-core', 'lib'))
require 'data_mapper'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/spec.db")

