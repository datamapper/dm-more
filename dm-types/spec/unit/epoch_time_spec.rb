require 'spec_helper'

try_spec do
  describe DataMapper::Types::EpochTime do
    describe '.dump' do
      describe 'when given Time instance' do
        before :all do
          @input = Time.now
        end

        it 'returns timestamp' do
          DataMapper::Types::EpochTime.dump(@input, :property).should == @input.to_i
        end
      end

      describe 'when given DateTime instance' do
        before :all do
          @input = DateTime.now
        end

        it 'returns timestamp' do
          DataMapper::Types::EpochTime.dump(@input, :property).should == Time.parse(@input.to_s).to_i
        end
      end

      describe 'when given an integer' do
        before :all do
          @input = Time.now.to_i
        end

        it 'returns value as is' do
          DataMapper::Types::EpochTime.dump(@input, :property).should == @input
        end
      end

      describe 'when given nil' do
        before :all do
          @input = nil
        end

        it 'returns value as is' do
          DataMapper::Types::EpochTime.dump(@input, :property).should == @input
        end
      end
    end

    describe '.load' do
      describe 'when value is nil' do
        it 'returns nil' do
          DataMapper::Types::EpochTime.load(nil, :property).should == nil
        end
      end

      describe 'when value is an integer' do
        it 'returns time object from timestamp' do
          t = Time.now.to_i
          DataMapper::Types::EpochTime.load(Time.now.to_i, :property).should == Time.at(t)
        end
      end
    end
  end
end
