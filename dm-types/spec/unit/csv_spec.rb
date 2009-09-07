require 'spec_helper'

try_spec do
  describe DataMapper::Types::Csv do
    describe '.load' do
      describe 'when argument is a comma separated string' do
        before :all do
          @input  = 'uno,due,tre'
          @result = DataMapper::Types::Csv.load(@input, :property)
        end

        it 'parses the argument using CVS parser' do
          @result.should == [ %w[ uno due tre ] ]
        end
      end

      describe 'when argument is an empty array' do
        before :all do
          @input    = []
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it 'does not change the input' do
          @result.should == @input
        end
      end

      describe 'when argument is an empty hash' do
        before :all do
          @input    = {}
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end

      describe 'when argument is nil' do
        before :all do
          @input    = nil
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end

      describe 'when argument is an integer' do
        before :all do
          @input    = 7
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end

      describe 'when argument is a float' do
        before :all do
          @input    = 7.0
          @result   = DataMapper::Types::Csv.load(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end
    end

    describe '.dump' do
      describe 'when value is a list of lists' do
        before :all do
          @input  = [ %w[ uno due tre ], %w[ uno dos tres ] ]
          @result = DataMapper::Types::Csv.dump(@input, :property)
        end

        it 'dumps value to comma separated string' do
          @result.should == "uno,due,tre\nuno,dos,tres\n"
        end
      end

      describe 'when value is a string' do
        before :all do
          @input  = 'beauty hides in the deep'
          @result = DataMapper::Types::Csv.dump(@input, :property)
        end

        it 'returns input as is' do
          @result.should == @input
        end
      end

      describe 'when value is nil' do
        before :all do
          @input  = nil
          @result = DataMapper::Types::Csv.dump(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end

      describe 'when value is a hash' do
        before :all do
          @input  = { :library => 'DataMapper', :language => 'Ruby' }
          @result = DataMapper::Types::Csv.dump(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end
    end
  end
end
