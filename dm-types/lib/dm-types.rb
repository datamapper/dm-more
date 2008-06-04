require 'rubygems'
require 'pathname'

gem 'dm-core', '=0.9.1'
require 'data_mapper'

dir = Pathname(__FILE__).dirname.expand_path / 'dm-types'

require dir / 'csv'
require dir / 'enum'
require dir / 'epoch_time'
require dir / 'file_path'
require dir / 'flag'
require dir / 'ip_address'
require dir / 'uri'
require dir / 'yaml'
require dir / 'serial'
