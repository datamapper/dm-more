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
      @adapter.should_receive(:http_post).with('/books.xml', @book.to_xml)
      @book.save
    end
  end
end