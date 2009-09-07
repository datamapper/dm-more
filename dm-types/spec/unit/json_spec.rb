require 'spec_helper'
require 'shared/identity_function_group'

try_spec do
  describe DataMapper::Types::Json do
    describe '.load' do
      describe 'when nil is provided' do
        it 'returns nil' do
          DataMapper::Types::Json.load(nil, :property).should be_nil
        end
      end

      describe 'when Json encoded primitive string is provided' do
        it 'returns decoded value as Ruby string' do
          DataMapper::Types::Json.load(JSON.dump(:value => 'JSON encoded string'), :property).should == { 'value' => 'JSON encoded string' }
        end
      end

      describe 'when something else is provided' do
        it 'raises ArgumentError with a meaningful message' do
          lambda {
            DataMapper::Types::Json.load(:sym, :property)
          }.should raise_error(ArgumentError, '+value+ of a property of JSON type must be nil or a String')
        end
      end
    end

    describe '.dump' do
      describe 'when nil is provided' do
        it 'returns nil' do
          DataMapper::Types::Json.dump(nil, :property).should be_nil
        end
      end

      describe 'when Json encoded primitive string is provided' do
        it 'does not do double encoding' do
          DataMapper::Types::Json.dump('Json encoded string', :property).should == 'Json encoded string'
        end
      end

      describe 'when regular Ruby string is provided' do
        it 'dumps argument to Json' do
          DataMapper::Types::Json.dump('dump me (to JSON)', :property).should == 'dump me (to JSON)'
        end
      end

      describe 'when Ruby array is provided' do
        it 'dumps argument to Json' do
          DataMapper::Types::Json.dump([1, 2, 3], :property).should == '[1,2,3]'
        end
      end

      describe 'when Ruby hash is provided' do
        it 'dumps argument to Json' do
          DataMapper::Types::Json.dump({ :datamapper => 'Data access layer in Ruby' }, :property).
            should == '{"datamapper":"Data access layer in Ruby"}'
        end
      end
    end

    describe '.typecast' do
      class SerializeMe
        attr_accessor :name
      end

      describe 'when given instance of a Hash' do
        before :all do
          @input = { :library => 'DataMapper' }

          @result = DataMapper::Types::Json.typecast(@input, :property)
        end

        it_should_behave_like 'identity function'
      end

      describe 'when given instance of an Array' do
        before :all do
          @input = %w[ dm-core dm-more ]

          @result = DataMapper::Types::Json.typecast(@input, :property)
        end

        it_should_behave_like 'identity function'
      end

      describe 'when given nil' do
        before :all do
          @input = nil

          @result = DataMapper::Types::Json.typecast(@input, :property)
        end

        it_should_behave_like 'identity function'
      end

      describe 'when given JSON encoded value' do
        before :all do
          @input = '{ "value": 11 }'

          @result = DataMapper::Types::Json.typecast(@input, :property)
        end

        it 'decodes value from JSON' do
          @result.should == { 'value' => 11 }
        end
      end

      describe 'when given instance of a custom class' do
        before :all do
          @input      = SerializeMe.new
          @input.name = 'Hello!'

          # @result = DataMapper::Types::Json.typecast(@input, :property)
        end

        it 'attempts to load value from JSON string'
      end
    end
  end
end
