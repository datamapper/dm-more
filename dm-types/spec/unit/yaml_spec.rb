require 'spec_helper'
require 'shared/identity_function_group'

try_spec do
  describe DataMapper::Types::Yaml do
    describe '.load' do
      describe 'when nil is provided' do
        it 'returns nil' do
          DataMapper::Types::Yaml.load(nil, :property).should be_nil
        end
      end

      describe 'when YAML encoded primitive string is provided' do
        it 'returns decoded value as Ruby string' do
          DataMapper::Types::Yaml.load("--- yaml string\n", :property).should == 'yaml string'
        end
      end

      describe 'when something else is provided' do
        it 'raises ArgumentError with a meaningful message' do
          lambda {
            DataMapper::Types::Yaml.load(:sym, :property)
          }.should raise_error(ArgumentError, '+value+ of a property of YAML type must be nil or a String')
        end
      end
    end

    describe '.dump' do
      describe 'when nil is provided' do
        it 'returns nil' do
          DataMapper::Types::Yaml.dump(nil, :property).should be_nil
        end
      end

      describe 'when YAML encoded primitive string is provided' do
        it 'does not do double encoding' do
          DataMapper::Types::Yaml.dump("--- yaml encoded string\n", :property).should == "--- yaml encoded string\n"
        end
      end

      describe 'when regular Ruby string is provided' do
        it 'dumps argument to YAML' do
          DataMapper::Types::Yaml.dump('dump me (to yaml)', :property).should == "--- dump me (to yaml)\n"
        end
      end

      describe 'when Ruby array is provided' do
        it 'dumps argument to YAML' do
          DataMapper::Types::Yaml.dump([1, 2, 3], :property).should == "--- \n- 1\n- 2\n- 3\n"
        end
      end

      describe 'when Ruby hash is provided' do
        it 'dumps argument to YAML' do
          DataMapper::Types::Yaml.dump({ :datamapper => 'Data access layer in Ruby' }, :property).should == "--- \n:datamapper: Data access layer in Ruby\n"
        end
      end
    end

    describe '.typecast' do
      class SerializeMe
        attr_accessor :name
      end

      describe 'given a number' do
        before :all do
          @input  = 15
          @result = 15
        end

        it_should_behave_like 'identity function'
      end

      describe 'given an Array instance' do
        before :all do
          @input  = ['dm-core', 'dm-more']
          @result = ['dm-core', 'dm-more']
        end

        it_should_behave_like 'identity function'
      end

      describe 'given a Hash instance' do
        before :all do
          @input  = { :format => 'yaml' }
          @result = { :format => 'yaml' }
        end

        it_should_behave_like 'identity function'
      end

      describe 'given a plain old Ruby object' do
        before :all do
          @input      = SerializeMe.new
          @input.name = 'yamly'

          @result = @input
        end

        it_should_behave_like 'identity function'
      end
    end
  end
end
