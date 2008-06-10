require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + '../lib/rest_adapter'

#To run these specs, you must have a REST Application running on port 3001 on your localhost
#The app is expected to implement the REST API for CRUD operations on a Book

DataMapper.setup(:default, {
  :adapter  => 'rest',
  :format => 'xml',
  :host => 'localhost',
  :port => '3001'
})

class Book
  include DataMapper::Resource
  property :id,         Integer, :serial => true
  property :title,      String
  property :author,     String
  property :created_at, DateTime
end

describe DataMapper::Adapters::RestAdapter do
  
  before :all do
    @adapter = DataMapper::Repository.adapters[:default]
    @no_connection = false
    unless @no_connection
      begin
        @adapter.send(:http_post, "/books.xml", "")
      rescue Errno::ECONNREFUSED
        @no_connection = true
      end
    end
  end
  
  it "should be able to get all the books" do
    check_connection
    pending "Not Implemented"
    Book.all.should_not be_empty
  end

  it "should be able to create a book" do
    check_connection
    pending "No connection" if @no_connection
    new_book.save
  end

  def new_book(options={})
    Book.new(options.merge({:title => "Hello, World!", :author => "Anonymous"}))
  end

  def check_connection
    pending "Could not connect to #{@adapter.uri[:host]}:#{@adapter.uri[:port]}" if @no_connection
  end

end