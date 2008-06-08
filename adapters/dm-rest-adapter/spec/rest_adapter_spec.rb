require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/rest_adapter'

DataMapper.setup(:default, {
  :adapter  => 'rest',
  :format => 'xml',
  :base_url => 'http://whatever.com/api'
})

class Book
  include DataMapper::Resource
  property :id,         Integer, :serial => true
  property :title,      String
  property :author,     String
  property :created_at, DateTime
end

describe "The REST Adapter" do
  it "should be able to create a book" do
    pending
    Book.create(:title => "Hello, World!", :author => "Anonymous")
  end
  it "should be able to get all the books" do
    pending
    Book.all.should_not be_empty
  end
end