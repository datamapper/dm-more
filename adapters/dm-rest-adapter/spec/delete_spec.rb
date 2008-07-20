$LOAD_PATH << File.dirname(__FILE__)
require 'spec_helper'

describe 'A REST adapter' do
  
  before do
    @adapter = DataMapper::Repository.adapters[:default]
  end
  
  describe 'when deleting an existing resource' do
    before do
      @book = Book.new(:title => 'Hello, World!', :author => 'Anonymous')
      @book.stub!(:new_record?).and_return(false)
    end
    
    it 'should do an HTTP DELETE' do
      @adapter.should_receive(:http_delete)
      @book.destroy
    end
    
  end
end