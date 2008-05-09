require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'

  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  # do something

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
