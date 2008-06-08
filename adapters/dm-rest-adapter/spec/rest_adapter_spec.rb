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

describe Book do
  it "should use 'books' for the storage name" do
    Book.storage_name.should == "books"
  end
  it "should be able to get all the books" do
    pending
    Book.all.should_not be_empty
  end
end

describe "A Book" do
  before do
    @book = Book.new(:title => "Hello, World!", :author => "Anonymous")
  end
  it "should be able to render itself as HTTP Post Data" do
    pending "Need a method to convert a resource to HTTP Post Data"
    @book.to_http_post_data.should == "book[name]=Hello%2C+World&book[author]=Anonymous"
  end
  it "should be able to create a book" do
    pending
    @book.save
  end
end