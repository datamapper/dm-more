require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + '../lib/rest_adapter'

#To run these specs, you must have a REST Application running on port 3001 on your localhost
#The app is expected to implement the REST API for CRUD operations on a Book

DataMapper.setup(:default, {
  :adapter  => 'rest',
  :format => 'xml',
  :base_url => 'http://localhost:3001'
})

class Book
  include DataMapper::Resource
  property :id,         Integer, :serial => true
  property :title,      String
  property :author,     String
  property :created_at, DateTime
end

describe Book do
  it "should be able to get all the books" do
    pending "Not Implemented"
    Book.all.should_not be_empty
  end
end

describe "A Book" do
  before do
    @book = Book.new(:title => "Hello, World!", :author => "Anonymous")
  end
  it "should be able to create a book" do
    @book.save
  end
end