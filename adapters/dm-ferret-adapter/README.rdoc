This is a DataMapper plugin for Ferret.

= Setup code

For a single process site, use the ferret index directly:

  DataMapper.setup :search, "ferret:///path/to/index"

For a multi-process site, use the distributed index by running `ferret start`
inside your project's directory and then setting up the :search repository:

  DataMapper.setup :search, "ferret:///tmp/ferret_index.sock"

= Sample Code

require 'rubygems'
require "dm-core"
require "dm-is-searchable"

DataMapper.setup(:default, "sqlite3::memory:")
DataMapper.setup(:search, "ferret://#{Pathname(__FILE__).dirname.expand_path.parent + "index"}")

class Image
  include DataMapper::Resource
  property :id, Serial
  property :title, String

  is :searchable # this defaults to :search repository, you could also do
  # is :searchable, :repository => :ferret

end

class Story
  include DataMapper::Resource
  property :id, Serial
  property :title, String
  property :author, String

  repository(:search) do
    # We only want to search on id and title.
    properties(:search).clear
    property :id, Serial
    property :title, String
  end

  is :searchable

end

Image.auto_migrate!
Story.auto_migrate!
image = Image.create(:title => "Oil Rig");
story = Story.create(:title => "Big Oil", :author => "John Doe") }

puts Image.search(:title => "Oil Rig").inspect # => [<Image title="Oil Rig">]

# For info on this, see DM::Repository#search and DM::Adapters::FerretAdapter#search.
puts repository(:search).search('title:"Oil"').inspect # => { Image => ["1"], Story => ["1"] }

image.destroy

puts Image.search(:title => "Oil Rig").inspect # => []
