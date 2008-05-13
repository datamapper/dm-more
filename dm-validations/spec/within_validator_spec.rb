require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

describe DataMapper::Validate::WithinValidator do
  before(:all) do
    class Telephone
      include DataMapper::Resource
      property :id, Integer, :serial => true
      property :type_of_number, String, :auto_validation => false
      validates_within :type_of_number, :set => ['Home','Work','Cell']
    end

    class Reciever
      include DataMapper::Resource
      property :id, Integer, :serial => true
      property :holder, String, :auto_validation => false, :default => 'foo'
      validates_within :holder, :set => ['foo', 'bar', 'bang']
    end
  end

  it "should validate a value on an instance of a resource within a predefined
      set of values" do
    tel = Telephone.new
    tel.valid?.should_not == true
    tel.errors.full_messages.first.should == 'Type of number must be one of [Home, Work, Cell]'

    tel.type_of_number = 'Cell'
    tel.valid?.should == true
  end

  it "should validate a value by its default" do
    tel = Reciever.new
    tel.should be_valid
  end
end
