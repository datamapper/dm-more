require 'spec_helper'

try_spec do
  describe DataMapper::Types::FilePath do
    before do
      @input = '/usr/bin/ruby'
      @path  = Pathname.new(@input)
    end

    describe '.dump' do
      describe 'when input is a string' do
        it 'does not modify input' do
          DataMapper::Types::FilePath.dump(@input, :property).should == @input
        end
      end

      describe 'when input is nil' do
        it 'returns nil' do
          DataMapper::Types::FilePath.dump(nil, :property).should be_nil
        end
      end

      describe 'when input is a blank string' do
        it 'returns nil' do
          DataMapper::Types::FilePath.dump('', :property).should be_nil
        end
      end
    end

    describe '.load' do
      describe 'when value is a non-blank file path' do
        it 'returns Pathname for a path' do
          DataMapper::Types::FilePath.load(@input, :property).should == @path
        end
      end

      describe 'when value is nil' do
        it 'return nil' do
          DataMapper::Types::FilePath.load(nil, :property).should be_nil
        end
      end

      describe 'when value is a blank string' do
        it 'returns nil' do
          DataMapper::Types::FilePath.load('', :property).should be_nil
        end
      end
    end

    describe '.typecast' do
      describe 'when a Pathname is given' do
        it 'does not modify input' do
          DataMapper::Types::FilePath.typecast(@path, :property).should == @path
        end
      end

      describe 'when a nil is given' do
        it 'does not modify input' do
          DataMapper::Types::FilePath.typecast(nil, :property).should == nil
        end
      end

      describe 'when a string is given' do
        it 'returns Pathname for given path' do
          DataMapper::Types::FilePath.typecast(@input, :property).should == @path
        end
      end
    end
  end
end
