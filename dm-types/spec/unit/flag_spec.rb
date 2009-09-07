require 'spec_helper'

describe 'factory method for Flag type', :shared => true do
  it 'creates a Class' do
    DataMapper::Types::Flag.new.should be_instance_of(Class)
  end

  it 'creates unique a Class each call' do
    DataMapper::Types::Flag.new.should_not == DataMapper::Types::Flag.new
  end

  it 'builds up flags map from arguments' do
    DataMapper::Types::Flag.new(:first, :second, :third).flag_map.values.should == [ :first, :second, :third ]
  end

  it 'should create keys that is +1 for every increment for the @flag_map hash, staring at 0' do
    DataMapper::Types::Flag.new(:one, :two, :three, :four, :five).flag_map.keys.should include(0, 1, 2, 3, 4)
  end
end

try_spec do
  describe DataMapper::Types::Flag do
    describe '.new' do
      it_should_behave_like 'factory method for Flag type'
    end

    describe '.[]' do
      it_should_behave_like 'factory method for Flag type'
    end

    describe '.dump' do
      before :all do
        @flag = DataMapper::Types::Flag[:first, :second, :third, :fourth, :fifth]
      end

      describe 'when argument matches a value in the flag map' do
        before :all do
          @result = @flag.dump(:first, :property)
        end

        it 'returns flag bit of value' do
          @result.should == 1
        end
      end

      describe 'when argument matches 2nd value in the flag map' do
        before :all do
          @result = @flag.dump(:second, :property)
        end

        it 'returns flag bit of value' do
          @result.should == 2
        end
      end

      describe 'when argument matches multiple Symbol values in the flag map' do
        before :all do
          @result = @flag.dump([ :second, :fourth ], :property)
        end

        it 'builds binary flag from key values of all matches' do
          @result.should == 10
        end
      end

      describe 'when argument matches multiple string values in the flag map' do
        before :all do
          @result = @flag.dump(['first', 'second', 'third', 'fourth', 'fifth'], :property)
        end

        it 'builds binary flag from key values of all matches' do
          @result.should == 31
        end
      end

      describe 'when argument does not match a single value in the flag map' do
        before :all do
          @result = @flag.dump(:zero, :property)
        end

        it 'returns zero' do
          @result.should == 0
        end
      end
    end

    describe '.load' do
      before :all do
        @flag = DataMapper::Types::Flag[:uno, :dos, :tres, :cuatro, :cinco]
      end

      describe 'when argument matches a key in the flag map' do
        before :all do
          @result = @flag.load(4,  :property)
        end

        it 'returns array with a single matching element' do
          @result.should == [ :tres ]
        end
      end

      describe 'when argument matches multiple keys in the flag map' do
        before :all do
          @result = @flag.load(10, :property)
        end

        it 'returns array of matching values' do
          @result.should == [ :dos, :cuatro ]
        end
      end

      describe 'when argument does not match a single key in the flag map' do
        before :all do
          @result = @flag.load(nil, :property)
        end

        it 'returns an empty array' do
          @result.should == []
        end
      end
    end
  end
end
