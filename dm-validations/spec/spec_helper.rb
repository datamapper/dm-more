require 'rubygems'
gem 'rspec', '>=1.1.3'
require 'spec'
require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/dm-validations'

HAS_SQLITE3 = begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'
  DataMapper.setup(:sqlite3, ENV['SQLITE3_SPEC_URI'] || 'sqlite3::memory:')
  true
rescue Gem::LoadError
  warn "Could not load do_sqlite3: #{$!}"
  false
end

LOG_PATH = Pathname(__FILE__).dirname.expand_path.to_s + '/sql.log'
FileUtils.touch LOG_PATH

DataMapper::Logger.new(LOG_PATH, 0)
at_exit { DataMapper.logger.close }
