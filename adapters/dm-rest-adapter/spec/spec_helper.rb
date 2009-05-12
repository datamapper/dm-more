require 'pathname'
require 'rubygems'

gem 'dm-core', '0.10.0'
require 'dm-core'

gem 'rspec', '>1.1.12'
require 'spec'

ROOT = Pathname(__FILE__).dirname.parent.expand_path

# use local dm-serializer if running from dm-more directly
lib = ROOT.parent.parent.join('dm-serializer', 'lib').expand_path
$LOAD_PATH.unshift(lib) if lib.directory?

require ROOT + 'lib/rest_adapter'

load ROOT + 'config/database.rb.example'

class Book
  include DataMapper::Resource
  property :author,     String
  property :created_at, DateTime
  property :id,         Serial
  property :title,      String
end
