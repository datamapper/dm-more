require 'pathname'

dir = Pathname(__FILE__).dirname.expand_path + 'sql'

require dir + 'table_creator'
require dir + 'table_modifier'
require dir + 'sqlite3'
require dir + 'mysql'
require dir + 'postgresql'
