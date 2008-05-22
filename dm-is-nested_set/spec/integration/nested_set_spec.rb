require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Is::NestedSet' do
    before :all do
      class Category
        include DataMapper::Resource
        include DataMapper::Is::NestedSet
        
        property :id, Integer, :serial => true
        property :name, String
        
        # is :nested_set ?

        auto_migrate!(:default)
      end
      
      Category.create!(:parent_id => nil, :lft => 1,  :rgt => 20, :name => "Electronics")
      Category.create!(:parent_id => 1, :lft => 2,  :rgt => 9,  :name => "Televisions")
      Category.create!(:parent_id => 2, :lft => 3,  :rgt => 4,  :name => "Tube")
      Category.create!(:parent_id => 2, :lft => 5,  :rgt => 6,  :name => "LCD")
      Category.create!(:parent_id => 2, :lft => 7,  :rgt => 8,  :name => "Plasma")
      Category.create!(:parent_id => 1, :lft => 10, :rgt => 19, :name => "Portable Electronics")
      Category.create!(:parent_id => 6, :lft => 11, :rgt => 14, :name => "MP3 Players")
      Category.create!(:parent_id => 7, :lft => 12, :rgt => 13, :name => "Flash")
      Category.create!(:parent_id => 6, :lft => 15, :rgt => 16, :name => "CD Players")
      Category.create!(:parent_id => 6, :lft => 17, :rgt => 18, :name => "2 Way Radios")
      
    end
    
    it 'should find all record' do
      Category.all.length.should == 10
    end
    
    describe 'Class#root' do
      it 'should return the toplevel node' do
        Category.root.name.should == "Electronics"
      end
    end
    
    describe 'Class#leaves' do
      it 'should return all nodes without descendants' do
        repository(:default) do
          Category.leaves.length.should == 6
        end
      end
    end
    
    describe '#ancestors' do
      it 'should return ancestors in an array' do
        repository(:default) do |repos|       
          Category.get(8).ancestors.map{|a|a.name}.should == ["Electronics","Portable Electronics","MP3 Players"]
        end
      end
    end
    
    describe '#children' do
      it 'should return children of node' do
        r = Category.root
        r.children.length.should == 2
        
        t = r.children.first
        t.children.length.should == 3
        t.children.first.name.should == "Tube"
        t.children[2].name.should == "Plasma"
      end
    end
    
    describe '#descendants and #self_and_descendants' do
      it 'should return all subnodes of node' do
        repository(:default) do
          r = Category.root
          r.self_and_descendants.length.should == 10
          r.descendants.length.should == 9
          
          t = r.children[1]
          t.descendants.length.should == 4
          t.descendants.map{|a|a.name}.should == ["MP3 Players","Flash","CD Players","2 Way Radios"]
        end
      end
    end
    
    describe '#leaves' do
      it 'should return all subnodes of node without descendants' do
        repository(:default) do
          r = Category.root
          r.leaves.length.should == 6
          
          t = r.children[1]
          t.leaves.length.should == 3
        end
      end
    end
    
  end # describe DataMapper::Is::NestedSet
end
