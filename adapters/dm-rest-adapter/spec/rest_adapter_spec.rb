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

describe "A REST adapter" do
  
  describe "when saving a resource" do
  
    before do
      @book = Book.new(:title => "Hello, World!", :author => "Anonymous")
      @adapter = DataMapper::Repository.adapters[:default]
    end
  
    it "should make an HTTP Post" do
      @adapter.should_receive(:http_post).with("/books.xml", @book.to_xml)
      @book.save
    end
  
    it "should get an id" do
      @book.save
      @book.id.should_not be_nil
    end
  end
  
  describe "when getting one resource" do
    
    describe "if the resource exists" do
    
      before do
        book_xml = <<-BOOK
        <book>
          <author>Stephen King</author>
          <created-at type="datetime">2008-06-08T17:03:07Z</created-at>
          <id type="integer">2</id>
          <title>The Shining</title>
          <updated-at type="datetime">2008-06-08T17:03:07Z</updated-at>
        </book>
        BOOK
        @id = 1
        @response = mock(Net::HTTPResponse)
        @response.stub!(:body).and_return(book_xml)
        @adapter.stub!(:http_get).and_return(@response)
      end
        
      it "should return the resource" do
        book = Book.get(@id)
        puts book.inspect
        book.id.should == 1
      end
    end
    
    describe "if the resource does not exist" do
      it "should return nil"
    end
  end
  
  describe "when getting all resource of a particular type" do
    it "should get a non-empty list" do
    end
  end

end