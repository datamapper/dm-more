require 'spec_helper'

try_spec do
  describe DataMapper::Types::URI do
    before do
      @uri_str = 'http://example.com/path/to/resource/'
      @uri     = Addressable::URI.parse(@uri_str)
    end

    describe '.dump' do
      it 'returns the URI as a String' do
        DataMapper::Types::URI.dump(@uri, :property).should == @uri_str
      end

      describe 'when given nil' do
        it 'returns nil' do
          DataMapper::Types::URI.dump(nil, :property).should be_nil
        end
      end

      describe 'when given an empty string' do
        it 'returns an empty URI' do
          DataMapper::Types::URI.dump('', :property).should == ''
        end
      end
    end

    describe '.load' do
      it 'returns the URI as Addressable' do
        DataMapper::Types::URI.load(@uri_str, :property).should == @uri
      end

      describe 'when given nil' do
        it 'returns nil' do
          DataMapper::Types::URI.load(nil, :property).should be_nil
        end
      end

      describe 'if given an empty String' do
        it 'returns an empty URI' do
          DataMapper::Types::URI.load('', :property).should == Addressable::URI.parse('')
        end
      end
    end

    describe '.typecast' do
      describe 'given instance of Addressable::URI' do
        it 'does nothing' do
          DataMapper::Types::URI.typecast(@uri, :property).should == @uri
        end
      end

      describe 'when given a string' do
        it 'delegates to .load' do
          DataMapper::Types::URI.typecast(@uri_str, :property).should == @uri
        end
      end
    end
  end
end
