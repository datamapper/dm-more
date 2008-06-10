require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'lib/rest_adapter'

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

describe Book do

  describe "when saving" do

    before do
      @book = Book.new(:title => "Hello, World!", :author => "Anonymous")
      @adapter = DataMapper::Repository.adapters[:default]
    end
  
    it "should make an HTTP Post" do
      @adapter.should_receive(:http_post).with("/books.xml", @book.to_xml)
      @book.save
    end

    it "should set the id" do
      @book.save
      @book.id.should_not be_nil
    end

  end

end