require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

begin
  gem 'do_sqlite3', '=0.9.0'
  require 'do_sqlite3'
  
  DataMapper.setup(:sqlite3, "sqlite3://#{DB_PATH}")

  describe DataMapper::Validate::NumericValidator do
    before(:all) do
      class Bill
        include DataMapper::Resource
        include DataMapper::Validate
        property :amount_1, String, :auto_validation => false   
        property :amount_2, Float, :auto_validation => false   

      
        validates_numericalnes_of :amount_1, :amount_2      
      end
    
      class Hillary
        include DataMapper::Resource
        include DataMapper::Validate
        property :amount_1, Float, :auto_validation => false, :default => 0.01
        validates_numericalnes_of :amount_1
      
      end
    end
  
    it "should validate a floating point value on the instance of a resource" do
      b = Bill.new
      b.valid?.should_not == true
      b.amount_1 = 'ABC'
      b.amount_2 = 27.343
      b.valid?.should_not == true
      b.amount_1 = '34.33'
      b.valid?.should == true    
    end
  
    it "should validate an integer value on the instance of a resource" do
      class Bill
        property :quantity_1, String, :auto_validation => false   
        property :quantity_2, Fixnum, :auto_validation => false      
    
        validators.clear!
        validates_numericalnes_of :quantity_1, :quantity_2, :integer_only => true
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

rescue LoadError => e
  describe 'do_sqlite3' do
    it 'should be required' do
      fail "validation specs not run! Could not load do_sqlite3: #{e}"
    end
  end
end
