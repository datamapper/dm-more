require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

include DataMapper::Types

begin
  gem 'bcrypt-ruby', '~>2.0.3'
  require 'bcrypt'
rescue LoadError
  skip_tests = true
  puts "Skipping bcrypt tests, please do gem install bcrypt-ruby"
end

describe "DataMapper::Types::BCryptHash" do
  unless skip_tests

    before :all do
      @clear_password   = "DataMapper R0cks!"
      @crypted_password = BCrypt::Password.create(@clear_password)

      @nonstandard_type = 1

      class TestType
        @a = 1
        @b = "Hi There"
      end
      @nonstandard_type2 = TestType.new
    end

    describe ".dump" do
      describe "when argument is a string" do
        before :all do
          @input  = "DataMapper"
          @result = BCryptHash.dump(@input, :property)
        end

        it "returns instance of BCrypt::Password" do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it "returns a string that is 60 characters long" do
          @result.should have(60).characters
        end
      end

      describe "when argument is nil" do
        before :all do
          @input  = nil
          @result = BCryptHash.dump(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end
    end



    describe ".load" do
      describe "when argument is a string" do
        before :all do
          @input  = "DataMapper"
          @result = BCryptHash.load(@crypted_password, :property)
        end

        it "returns instance of BCrypt::Password" do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it "returns a string that matches original" do
          @result.should == @clear_password
        end
      end


      describe "when argument is nil" do
        before :all do
          @input  = nil
          @result = BCryptHash.load(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end
    end

    describe ".typecast" do
      describe "when argument is a string" do
        before :all do
          @input  = "bcrypt hash"
          @result = BCryptHash.typecast(@input, :property)
        end

        it "casts argument to BCrypt::Password" do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it "casts argument to value that matches input" do
          @result.should == @input
        end
      end


      describe "when argument is a blank string" do
        before :all do
          @input  = ''
          @result = BCryptHash.typecast(@input, :property)
        end

        it "casts argument to BCrypt::Password" do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it "casts argument to value that matches input" do
          @result.should == @input
        end
      end


      describe "when argument is integer" do
        before :all do
          @input  = 2249
          @result = BCryptHash.typecast(@input, :property)
        end

        it "casts argument to BCrypt::Password" do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it "casts argument to value that matches input" do
          @result.should == @input
        end
      end


      describe "when argument is hash" do
        before :all do
          @input  = { :cryptic => "obscure" }
          @result = BCryptHash.typecast(@input, :property)
        end

        it "casts argument to BCrypt::Password" do
          @result.should be_an_instance_of(BCrypt::Password)
        end

        it "casts argument to value that matches input" do
          @result.should == @input
        end
      end


      describe "when argument is nil" do
        before :all do
          @input  = nil
          @result = BCryptHash.typecast(@input, :property)
        end

        it "returns nil" do
          @result.should be_nil
        end
      end
    end
  end
end
