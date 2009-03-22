require 'pathname'
require Pathname(__FILE__).dirname.parent.expand_path + 'spec_helper'

describe DataMapper::Types::Enum do

  describe ".new" do
    before :all do

    end
    it "should create a Class" do
      DataMapper::Types::Enum.new.should be_instance_of(Class)
    end

    it "should create unique a Class each call" do
      DataMapper::Types::Enum.new.should_not == DataMapper::Types::Enum.new
    end

    it "should use the arguments as the values in the @flag_map hash" do
      DataMapper::Types::Enum.new(:first, :second, :third).flag_map.values.should == [:first, :second, :third]
    end

    it "should create incremental keys for the @flag_map hash, staring at 1" do
      DataMapper::Types::Enum.new(:one, :two, :three, :four).flag_map.keys.should == (1..4).to_a
    end

    it "should have an Integer primitive type" do
      DataMapper::Types::Enum.new.primitive.should == Integer
    end
  end

  describe ".dump" do
    before(:each) do
      @enum = DataMapper::Types::Enum[:first, :second, :third]
    end

    it "should return the key of the value match from the flag map" do
      @enum.dump(:first, :property).should == 1
      @enum.dump(:second, :property).should == 2
      @enum.dump(:third, :property).should == 3
    end

    describe "when there is no match" do
      it "should return nil" do
        @enum.dump(:zero, :property).should be_nil
      end
    end
  end

  describe ".load" do
    before(:each) do
      @enum = DataMapper::Types::Enum[:uno, :dos, :tres]
    end

    it "should return the value of the key match from the flag map" do
      @enum.load(1, :property).should == :uno
      @enum.load(2, :property).should == :dos
      @enum.load(3, :property).should == :tres
    end

    describe "when there is no key" do
      it "should return nil" do
        @enum.load(-1, :property).should be_nil
      end
    end
  end

  describe ".typecast" do
    describe "of Enum created from a symbol" do
      before :all do
        @enum = DataMapper::Types::Enum[:uno]
      end

      describe "when given a symbol" do
        it "uses Enum type" do
          @enum.typecast(:uno,  :property).should == :uno
        end
      end

      describe "when given a string" do
        it "uses Enum type" do
          @enum.typecast("uno", :property).should == :uno
        end
      end

      describe "when given nil" do
        it "returns nil" do
          @enum.typecast( nil, :property).should == nil
        end
      end
    end


    describe "of Enum created from integer list" do
      before :all do
        @enum = DataMapper::Types::Enum[1, 2, 3]
      end

      describe "when given an integer" do
        it "uses Enum type" do
          @enum.typecast(1,   :property).should == 1
        end
      end

      describe "when given a float" do
        it "uses Enum type" do
          @enum.typecast(1.1, :property).should == 1
        end
      end

      describe "when given nil" do
        it "returns nil" do
          @enum.typecast( nil, :property).should == nil
        end
      end

    end


    describe "of Enum created from a string" do
      before :all do
        @enum = DataMapper::Types::Enum["uno"]
      end

      describe "when given a symbol" do
        it "uses Enum type" do
          @enum.typecast(:uno,  :property).should == "uno"
        end
      end

      describe "when given a string" do
        it "uses Enum type" do
          @enum.typecast("uno", :property).should == "uno"
        end
      end

      describe "when given nil" do
        it "returns nil" do
          @enum.typecast( nil, :property).should == nil
        end
      end
    end
  end
end
