require File.dirname(__FILE__) + "/spec_helper"

describe DataMapper::Is::Tree do
  
  before do
    class Tree
      include DataMapper::Resource
      
      property :id, Serial
      property :parent_id, Integer
    end
  end
  
  it "should create a parent relationship" do
    Tree.is :tree
    Tree.relationships.include?(:parent).should == true
  end
  
  it "should create a children relationship" do
    Tree.is :tree
    Tree.relationships.include?(:children).should == true
  end
  
  describe "parent relationship" do
    
    it "should set the class_name from the current class" do
      Tree.is :tree
      Tree.relationships[:parent].options[:class_name].should == Tree.name
    end
    
    it "should use the default child_key of :parent_id if none is supplied in the options" do
      Tree.is :tree
      Tree.relationships[:parent].options[:child_key].should == Array(:parent_id)
    end
    
    it "should use the child_key from the options if it is supplied" do
      Tree.is :tree, :child_key => :other_id
      Tree.relationships[:parent].options[:child_key].should == Array(:other_id)
    end
    
    it "should not set any order" do
      Tree.is :tree, :order => :parent_id
      Tree.relationships[:parent].options.include?(:order).should == false
    end
    
  end
  
  describe "children relationship" do
    
    it "should set the class_name from the current class" do
      Tree.is :tree
      Tree.relationships[:children].options[:class_name].should == Tree.name
    end
    
    it "should use the default child_key of :parent_id if none is supplied in the options" do
      Tree.is :tree
      Tree.relationships[:children].options[:child_key].should == Array(:parent_id)
    end
    
    it "should use the child_key from the options if it is supplied" do
      Tree.is :tree, :child_key => :other_id
      Tree.relationships[:children].options[:child_key].should == Array(:other_id)
    end
    
    it "should not set any order if none is supplied in the options" do
      Tree.is :tree
      Tree.relationships[:children].options.include?(:order).should == false
    end
    
    it "should use the order from the options if it is supplied" do
      Tree.is :tree, :order => :parent_id
      Tree.relationships[:children].options[:order].should == Array(:parent_id)
    end
    
  end
  
end