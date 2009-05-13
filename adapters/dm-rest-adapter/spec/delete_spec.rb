$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'

describe 'A REST adapter' do

  before do
    @adapter = DataMapper::Repository.adapters[:default]
  end

  describe 'when deleting an existing resource' do
    before do
      @book = Book.new(:id => 42, :title => 'Hello, World!', :author => 'Anonymous')
      @book.stub!(:saved?).and_return(true)
    end

    it 'should do an HTTP DELETE' do
      @adapter.send(:connection).should_receive(:http_delete).with('books/42')
      @book.destroy
    end

  end
end
