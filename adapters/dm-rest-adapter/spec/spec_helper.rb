require 'rubygems'
require File.dirname(__FILE__)+'/../lib/rest_adapter'

root = File.expand_path(File.dirname(__FILE__) + '/../')
# use local dm-serializer if running from dm-more directly
# lib = root.parent.parent.join('dm-serializer', 'lib').expand_path
# $LOAD_PATH.unshift(lib) if lib.directory?

load File.expand_path(root + '/config/database.rb')

class Book
  include DataMapper::Resource
  property :author,     String
  property :created_at, DateTime
  property :id,         Integer, :serial => true
  property :title,      String
end
