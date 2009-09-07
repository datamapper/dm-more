require 'spec_helper'

try_spec do
  describe DataMapper::Types::BCryptHash do
    before :all do
      @clear_password   = 'DataMapper R0cks!'
      @crypted_password = BCrypt::Password.create(@clear_password)

      @nonstandard_type = 1

      class TestType
        @a = 1
        @b = 'Hi There'
      end
      @nonstandard_type2 = TestType.new
    end

    describe '.dump' do
      describe 'when argument is a string' do
        before :all do
          @input  = 'DataMapper'
          @result = DataMapper::Types::BCryptHash.dump(@input, :property)
        end

        it 'returns instance of BCrypt::Password' do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it 'returns a string that is 60 characters long' do
          @result.should have(60).characters
        end
      end

      describe 'when argument is nil' do
        before :all do
          @input  = nil
          @result = DataMapper::Types::BCryptHash.dump(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end
    end

    describe '.load' do
      describe 'when argument is a string' do
        before :all do
          @input  = 'DataMapper'
          @result = DataMapper::Types::BCryptHash.load(@crypted_password, :property)
        end

        it 'returns instance of BCrypt::Password' do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it 'returns a string that matches original' do
          @result.should == @clear_password
        end
      end

      describe 'when argument is nil' do
        before :all do
          @input  = nil
          @result = DataMapper::Types::BCryptHash.load(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end
    end

    describe '.typecast' do
      describe 'when argument is a string' do
        before :all do
          @input  = 'bcrypt hash'
          @result = DataMapper::Types::BCryptHash.typecast(@input, :property)
        end

        it 'casts argument to BCrypt::Password' do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it 'casts argument to value that matches input' do
          @result.should == @input
        end
      end

      describe 'when argument is a blank string' do
        before :all do
          @input  = ''
          @result = DataMapper::Types::BCryptHash.typecast(@input, :property)
        end

        it 'casts argument to BCrypt::Password' do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it 'casts argument to value that matches input' do
          @result.should == @input
        end
      end

      describe 'when argument is integer' do
        before :all do
          @input  = 2249
          @result = DataMapper::Types::BCryptHash.typecast(@input, :property)
        end

        it 'casts argument to BCrypt::Password' do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it 'casts argument to value that matches input' do
          @result.should == @input
        end
      end

      describe 'when argument is hash' do
        before :all do
          @input  = { :cryptic => 'obscure' }
          @result = DataMapper::Types::BCryptHash.typecast(@input, :property)
        end

        it 'casts argument to BCrypt::Password' do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it 'casts argument to value that matches input' do
          @result.should == @input
        end
      end

      describe 'when argument is nil' do
        before :all do
          @input  = nil
          @result = DataMapper::Types::BCryptHash.typecast(@input, :property)
        end

        it 'returns nil' do
          @result.should be_nil
        end
      end
    end
  end
end
