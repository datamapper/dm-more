require 'pathname'
require Pathname(__FILE__).dirname.expand_path + 'spec_helper'

describe DataMapper::Validate::AbsentFieldValidator do
  before(:all) do
    class Kayak
      include DataMapper::Resource
      include DataMapper::Validate
      property :salesman, String, :auto_validation => false      
            
      validates_absence_of :salesman, :when => :sold    
    end
    
    class Pirogue
      include DataMapper::Resource
      include DataMapper::Validate
      property :salesman, String, :default => 'Layfayette'
      validates_absence_of :salesman, :when => :sold
    end
  end

  it "should validate the absense of a value on an instance of a resource" do
    kayak = Kayak.new
    kayak.valid_for_sold?.should == true
    
    kayak.salesman = 'Joe'
    kayak.valid_for_sold?.should_not == true    
  end
  
  it "should validate the absense of a value and ensure defaults" do
    pirogue = Pirogue.new
    pirogue.should_not be_valid_for_sold
  end
  
end
