require 'spec_helper'

try_spec do
  describe DataMapper::Types::Regexp  do
    describe '.load' do
      describe 'when argument is a string' do
        before :all do
          @input  = '[a-z]\d+'
          @result = DataMapper::Types::Regexp.load(@input, :property)
        end

        it 'create a regexp instance from argument' do
          @result.should == Regexp.new(@input)
        end
      end

      describe 'when argument is nil' do
        before :all do
          @input  = nil
          @result = DataMapper::Types::Regexp.load(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end
    end

    describe '.dump' do
      describe 'when argument is a regular expression' do
        before :all do
          @input  = /\d+/
          @result = DataMapper::Types::Regexp.dump(@input, :property)
        end

        it 'escapes the argument' do
          @result.should == '\\d+'
        end
      end

      describe 'when argument is nil' do
        before :all do
          @input = nil
          @result = DataMapper::Types::Regexp.dump(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end
    end
  end
end
