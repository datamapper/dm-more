$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'

describe 'A REST adapter' do

  before do
    @adapter = DataMapper::Repository.adapters[:default]
  end

  describe 'when updating an existing resource' do
    before do
      @book = Book.new(
        :id         => 42,
        :title      => 'Starship Troopers',
        :author     => 'Robert Heinlein',
        :created_at => DateTime.parse('2008-06-08T17:02:28Z')
      )

      @book.stub!(:new?).and_return(false)
      @book.title = 'Mary Had a Little Lamb'
    end

    it 'should do an HTTP PUT' do
      @adapter.send(:connection).should_receive(:http_put).with('books/42', @book.to_xml)
      @book.save
    end
  end
end
