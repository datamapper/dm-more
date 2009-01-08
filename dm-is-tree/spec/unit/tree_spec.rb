require File.dirname(__FILE__) + "/../spec_helper"

describe DataMapper::Is::Tree do
  
  before do
    class Tree
      include DataMapper::Resource
      
      property :id, Serial
      property :parent_id, Integer
      property :name, String
    end
  end
  
  it "should create a parent relationship" do
    Tree.is :tree
    Tree.relationships.should have_key(:parent)
  end
  
  it "should create a children relationship" do
    Tree.is :tree
    Tree.relationships.should have_key(:children)
  end
  
  it "should create a class method called roots" do
    Tree.is :tree
    Tree.should respond_to(:roots)
  end
  
  it "should create a class method called first_root" do
    Tree.is :tree
    Tree.should respond_to(:first_root)
  end
  
  it "should create an alias of class method first_root called root (ActiveRecord compatability)" do
	Tree.is :tree
	Tree.method(:first_root).should == Tree.method(:root)
  end
  
  it "should create an instance method called ancestors" do
	Tree.is :tree
	Tree.new.should respond_to(:ancestors)
  end
  
  it "should create an instance method called root" do
	Tree.is :tree
	Tree.new.should respond_to(:root)
  end
  
  it "should create an instance method called siblings" do
	Tree.is :tree
	Tree.new.should respond_to(:siblings)
  end
  
  it "should create an instance method called generation" do
	Tree.is :tree
	Tree.new.should respond_to(:generation)
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
      Tree.is :tree, :order => :name
      Tree.relationships[:parent].options.should_not have_key(:order)
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
      Tree.relationships[:children].options.should_not have_key(:order)
    end
    
    it "should use the order from the options if it is supplied" do
      Tree.is :tree, :order => :name
      Tree.relationships[:children].options[:order].should == Array(:name)
    end
    
  end
  
end