require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-validations'

DB_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/integration_test.db'
FileUtils.touch DB_PATH  
LOG_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/sql.log'
FileUtils.touch LOG_PATH

DataMapper::Logger.new(LOG_PATH, 0)
at_exit { DataMapper.logger.close }
