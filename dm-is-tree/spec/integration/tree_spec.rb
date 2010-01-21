require 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES

  describe DataMapper::Is::Tree do

    before(:all) do

      class Category
        include DataMapper::Resource

        property :id, Serial
        property :name, String

        is :tree
      end

      Category.auto_migrate!

      @root_a = Category.create(:name => 'a root')
      @root_b = Category.create(:name => 'b root')

      @child_a = Category.create(:name => 'a child', :parent => @root_a)
      @child_b = Category.create(:name => 'b child', :parent => @root_a)

      @grandchild_a = Category.create(:name => 'a grandchild', :parent => @child_a)
      @grandchild_b = Category.create(:name => 'b grandchild', :parent => @child_a)

    end

    describe "roots class method" do

      it "should return all instances where the child_key is nil" do
        Category.is :tree
        Category.roots.should == [@root_a, @root_b]
      end

      it "should use the order from the options if it is supplied" do
        Category.is :tree, :order => :name.desc
        Category.roots.should == [@root_b, @root_a]
      end

    end

    describe "first_root class method" do

      it "should return the first instance where the child_key is nil" do
        Category.is :tree
        Category.first_root.should == @root_a
      end

      it "should use the order from the options if it is supplied" do
        Category.is :tree, :order => :name.desc
        Category.first_root.should == @root_b
      end

    end

    describe "ancestors instance method" do

      it "should return the list of ancestors for the current node up to its root" do
        Category.is :tree
        @grandchild_a.ancestors.should == [@root_a, @child_a]
      end

    end

    describe "root instance method" do

      it "should return the root node for the current instance" do
        Category.is :tree
        @child_a.root.should == @root_a
      end
    end

    describe "siblings instance method" do

      it "should return all nodes which have the same parent as this node (excluding this node)" do
        Category.is :tree
        @child_a.siblings.should == [@child_b]
      end

    end

    describe "generation instance method" do

      it "should return all nodes which have the same parent as this node (including this node)" do
        Category.is :tree
        @child_a.generation.should == [@child_a, @child_b]
      end

    end

  end

end
