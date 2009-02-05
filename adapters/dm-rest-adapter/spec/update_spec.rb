$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'

describe 'A REST adapter' do

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

      @repository = DataMapper.repository

      @repository.scope do
        @book = Book.new(:id => 42,
                         :title => 'Starship Troopers',
                         :author => 'Robert Heinlein',
                         :created_at => DateTime.parse('2008-06-08T17:02:28Z'))
        @book.stub!(:new?).and_return(false)
        @repository.identity_map(Book)[@book.key] = @book
        @book.title = "Mary Had a Little Lamb"
      end
    end

    it 'should do an HTTP PUT' do
      adapter = @repository.adapter #DataMapper::Repository.adapters[:default]
      adapter.connection.should_receive(:http_put).with('/books/42', @book.to_xml)
      @repository.scope do
        @book.save
      end
    end
  end
end
