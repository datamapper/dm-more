$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'

describe 'A REST adapter' do

  before do
    @adapter = DataMapper::Repository.adapters[:default]
  end

  describe 'when saving a resource' do

    before do
      @book = Book.new(:title => 'Hello, World!', :author => 'Anonymous')
    end

    it 'should make an HTTP Post' do
      @adapter.connection.should_receive(:run_verb).with('post', @book.to_xml)
      @book.save
    end    
  end

  describe 'when deleting an existing resource' do
    before do
      @book = Book.new(:title => 'Hello, World!', :author => 'Anonymous')
      @book.stub!(:new_record?).and_return(false)
      @book.stub!(:id).and_return(1)
    end

    it 'should do an HTTP DELETE' do
      # TODO: Is it good returning receiving nil?                      
      @adapter.connection.should_receive(:http_delete)
      @book.destroy
    end

  end

  describe 'when getting one resource' do

    describe 'if the resource exists' do

      before do
        book_xml = <<-BOOK
        <?xml version='1.0' encoding='UTF-8'?>
        <book>
          <author>Stephen King</author>
          <created-at type='datetime'>2008-06-08T17:03:07Z</created-at>
          <id type='integer'>1</id>
          <title>The Shining</title>
          <updated-at type='datetime'>2008-06-08T17:03:07Z</updated-at>
        </book>
        BOOK
        @id = 1
        @response = mock(Net::HTTPResponse)
        @response.stub!(:body).and_return(book_xml)
        @adapter.connection.stub!(:http_get).and_return(@response)
      end

      it 'should return the resource' do
        book = Book.get(@id)
        book.should_not be_nil
        book.id.should be_an_instance_of(Fixnum)
        book.id.should == 1
      end

      it 'should do an HTTP GET' do
        @adapter.connection.should_receive(:http_get).with('/books/1.xml').and_return(@response)
        Book.get(@id)
      end

      it "it be equal to itself" do
        Book.get(@id).should == Book.get(@id)
      end
    end


    describe 'if the resource does not exist' do
      it 'should return nil' do
        @id = 1
        @response = mock(Net::HTTPNotFound)
        @response.stub!(:content_type).and_return('text/html')
        @response.stub!(:body).and_return('<html></html>')
        @adapter.connection.stub!(:http_get).and_return(@response)
        id = 4200
        Book.get(id).should be_nil
      end
    end
  end

  describe 'when getting all resource of a particular type' do
    before do
      books_xml = <<-BOOK
      <?xml version='1.0' encoding='UTF-8'?>
      <books type='array'>
        <book>
          <author>Ursula K LeGuin</author>
          <created-at type='datetime'>2008-06-08T17:02:28Z</created-at>
          <id type='integer'>1</id>
          <title>The Dispossed</title>
          <updated-at type='datetime'>2008-06-08T17:02:28Z</updated-at>
        </book>
        <book>
          <author>Stephen King</author>
          <created-at type='datetime'>2008-06-08T17:03:07Z</created-at>
          <id type='integer'>2</id>
          <title>The Shining</title>
          <updated-at type='datetime'>2008-06-08T17:03:07Z</updated-at>
        </book>
      </books>
      BOOK
      @response = mock(Net::HTTPResponse)
      @response.stub!(:body).and_return(books_xml)
      @adapter.connection.stub!(:http_get).and_return(@response)
    end

    it 'should get a non-empty list' do
      Book.all.should_not be_empty
    end

    it 'should receive one Resource for each entity in the XML' do
      Book.all.size.should == 2
    end

    it 'should do an HTTP GET' do
      @adapter.connection.should_receive(:http_get).and_return(@response)
      Book.first
    end
  end

  describe 'when updating an existing resource' do
    before do
      @books_xml = <<-XML
      <book>
        <id type='integer'>42</id>
        <title>Starship Troopers</title>
        <author>Robert Heinlein</author>
        <created-at type='datetime'>2008-06-08T17:02:28Z</created-at>
      </book>
      XML
      repository do |repo|
        @repository = repo
        @book = Book.new(:id => 42,
                         :title => 'Starship Troopers',
                         :author => 'Robert Heinlein',
                         :created_at => DateTime.parse('2008-06-08T17:02:28Z'))
        @book.instance_eval { @new_record = false }
        @repository.identity_map(Book)[@book.key] = @book
        @book.title = "Mary Had a Little Lamb"
      end
    end

    it 'should do an HTTP PUT' do                                                            
      @adapter.connection.should_receive(:http_put).with('/books/42.xml', @book.to_xml)
      @repository.scope do
        @book.save
      end
    end
  end  
end
