require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-validations'

begin

  require 'do_sqlite3'

  DB_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/integration_test.db'
  FileUtils.touch DB_PATH  
  LOG_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/sql.log'
  FileUtils.touch LOG_PATH
  DataMapper::Logger.new(LOG_PATH, 0)
  at_exit { DataMapper.logger.close }

  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")
  
  rescue LoadError
    describe 'do_sqlite3' do
      it 'should be required' do
        fail "validation specs not run! Could not load do_sqlite3: #{e}"
      end
    end
  end
  