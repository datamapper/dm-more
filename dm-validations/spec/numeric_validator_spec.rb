require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

class Bill # :nodoc:
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :amount_1, String, :auto_validation => false
  property :amount_2, Float, :auto_validation => false
  validates_is_number :amount_1, :amount_2
end

class Hillary # :nodoc:
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :amount_1, Float, :auto_validation => false, :default => 0.01
  validates_is_number :amount_1
end

describe DataMapper::Validate::NumericValidator do
  it "should validate a floating point value on the instance of a resource" do
    b = Bill.new
    b.should_not be_valid
    b.amount_1 = 'ABC'
    b.amount_2 = 27.343
    b.should_not be_valid
    b.amount_1 = '34.33'
    b.should be_valid
  end

  it "should validate an integer value on the instance of a resource" do
    class Bill
      property :quantity_1, String, :auto_validation => false
      property :quantity_2, Integer, :auto_validation => false

      validators.clear!
      validates_is_number :quantity_1, :quantity_2, :integer_only => true
    end
    b = Bill.new
    b.valid?.should_not == true
    b.quantity_1 = '12.334'
    b.quantity_2 = 27.343
    b.valid?.should_not == true
    b.quantity_1 = '34.33'
    b.quantity_2 = 22
    b.valid?.should_not == true
    b.quantity_1 = '34'
    b.valid?.should == true

  end

  it "should validate if a default fufills the requirements" do
    h = Hillary.new
    h.should be_valid
  end
end
