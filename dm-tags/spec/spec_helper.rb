require 'rubygems'
require 'spec'
require 'dm-core'
require 'dm-validations'
require File.dirname(__FILE__) + '/../lib/dm-tags'
require File.dirname(__FILE__) + '/classes'

DataMapper.setup(:default, 'sqlite3::memory:')
DataMapper.auto_migrate!
