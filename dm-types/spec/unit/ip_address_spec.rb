require 'spec_helper'

try_spec do
  describe DataMapper::Types::IPAddress do
    before :all do
      @stored = '81.20.130.1'
      @input  = IPAddr.new(@stored)
    end

    describe '.dump' do
      describe 'when argument is an IP address given as Ruby object' do
        before :all do
          @result = DataMapper::Types::IPAddress.dump(@input, :property)
        end

        it 'dumps input into a string' do
          @result.should == @stored
        end
      end

      describe 'when argument is nil' do
        before :all do
          @result = DataMapper::Types::IPAddress.dump(nil, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end

      describe 'when input is a blank string' do
        before :all do
          @result = DataMapper::Types::IPAddress.dump('', :property)
        end

        it 'retuns a blank string' do
          @result.should == ''
        end
      end
    end

    describe '.load' do
      describe 'when argument is a valid IP address as a string' do
        before :all do
          @result = DataMapper::Types::IPAddress.load(@stored, :property)
        end

        it 'returns IPAddr instance from stored value' do
          @result.should == @input
        end
      end

      describe 'when argument is nil' do
        before :all do
          @result = DataMapper::Types::IPAddress.load(nil, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end

      describe 'when argument is a blank string' do
        before :all do
          @result = DataMapper::Types::IPAddress.load('', :property)
        end

        it 'returns IPAddr instance from stored value' do
          @result.should == IPAddr.new('0.0.0.0')
        end
      end

      describe 'when argument is an Array instance' do
        before :all do
          @operation = lambda { DataMapper::Types::IPAddress.load([], :property) }
        end

        it 'raises ArgumentError with a meaningful message' do
          @operation.should raise_error(ArgumentError, '+value+ must be nil or a String')
        end
      end
    end

    describe '.typecast' do
      describe 'when argument is an IpAddr object' do
        before :all do
          @result = DataMapper::Types::IPAddress.typecast(@input, :property)
        end

        it 'does not change the value' do
          @result.should == @input
        end
      end

      describe 'when argument is a valid IP address as a string' do
        before :all do
          @result = DataMapper::Types::IPAddress.typecast(@stored, :property)
        end

        it 'instantiates IPAddr instance' do
          @result.should == @input
        end
      end
    end
  end
end
