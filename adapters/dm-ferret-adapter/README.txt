This is a DataMapper plugin for Ferret.

= Sample Code

require "rubygems"
require "dm-core"
require "dm-is-searchable"

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.setup(:search, "ferret://#{Pathname(__FILE__).dirname.expand_path.parent + "index"}")

class User
  include DataMapper::Resource
  property :id, Serial
  property :name, String

  is :searchable # this defaults to :search repository, you could also do
  # is :searchable, :repository => :ferret

end

repository(:default) { User.auto_migrate! }
repository(:default) { User.create(:name => "James") }

user = User.first

puts User.search(:name => "James").inspect # => [<User name="James">]

# For info on this, see DM::Repository#search and DM::Adapters::FerretAdapter#search.
puts repository(:search).search('name:"James"').inspect # => { User => ["1"] }

user.destroy

puts User.search(:name => "James").inspect # => []