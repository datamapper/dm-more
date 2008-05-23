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
        
        is_a_nested_set
        
        auto_migrate!(:default)
      end
      
    end
    
    before :each do 
      #Category.create!(:id => 1,:name => "Electronics")
      #Category.create!(:id => 2,:parent_id => 1,    :name => "Televisions")
      #Category.create!(:id => 3,:parent_id => 2,    :name => "Tube")
      #Category.create!(:id => 4,:parent_id => 2,    :name => "LCD")
      #Category.create!(:id => 5,:parent_id => 2,    :name => "Plasma")
      #Category.create!(:id => 6,:parent_id => 1,    :name => "Portable Electronics")
      #Category.create!(:id => 7,:parent_id => 6,    :name => "MP3 Players")
      #Category.create!(:id => 8,:parent_id => 7,    :name => "Flash")
      #Category.create!(:id => 9,:parent_id => 6,    :name => "CD Players")
      #Category.create!(:id => 10,:parent_id => 6,   :name => "2 Way Radios")
    end
    
    describe 'moving objects with #move_* #and place_node_at' do
      it 'should set left/right to when inserting new objects' do
        repository(:default) do
        
          c1 = Category.create!(:name => "Electronics")
          
          pos(c1).should == [1,2]
      
          c2 = Category.create(:name => "Televisions")
          c2.move_to_position(2)
          
          pos(c1,c2).should == [1,4, 2,3]
        
          c3 = Category.create(:name => "Portable Electronics")
          c3.move_to_position(2)
          
          pos(c1,c2,c3).should == [1,6, 4,5, 2,3]
          
          c3.move_to_position(6)
          
          pos(c1).should == [1,6]
          pos(c2).should == [2,3]
          pos(c3).should == [4,5]
        
          c4 = Category.create(:name => "Tube")
          c4.move_to_position(3)
          
          pos(c1).should == [1,8]
          pos(c2).should == [2,5]
          pos(c3).should == [6,7]
          pos(c4).should == [3,4]    
          
          c4.move_below(c3)
          pos(c1).should == [1,8]
          pos(c2).should == [2,3]
          pos(c3).should == [4,5]
          pos(c4).should == [6,7]
          
          c2.move_into(c4)
          pos(c1).should == [1,8]
          pos(c2).should == [5,6]
          pos(c3).should == [2,3]
          pos(c4).should == [4,7]
              
        end
      end
      
      it 'should set left/right when choosing a parent' do
        repository(:default) do
          Category.auto_migrate!(:default)
          
          c1 = Category.create!(:name => "New Electronics")
          
          c2 = Category.create!(:name => "OLED TVs", :parent => c1)
          
          pos(c1).should == [1,4]
          pos(c2).should == [2,3]
          
          c3 = Category.create(:name => "Portable Electronics")
          c3.parent=c1
          c3.save
          
          pos(c1).should == [1,6]
          pos(c2).should == [2,3]
          pos(c3).should == [4,5]
          
          c3.parent=c2
          c3.save
          
          pos(c1).should == [1,6]
          pos(c2).should == [2,5]
          pos(c3).should == [3,4]
          
          c3.parent=c1
          c3.move_into(c2)
          
          pos(c1).should == [1,6]
          pos(c2).should == [2,5]
          pos(c3).should == [3,4]
          
          c4 = Category.create(:name => "Tube", :parent => c2)
          c5 = Category.create(:name => "Flatpanel", :parent => c2)
          
          pos(c1).should == [1,10]
          pos(c2).should == [2,9]
          pos(c3).should == [3,4]
          pos(c4).should == [5,6]
          pos(c5).should == [7,8]
          
          c5.move_above c3
          pos(c3).should == [5,6]
          pos(c4).should == [7,8]
          pos(c5).should == [3,4]
          
        end
      end
    end

    # 
    # describe 'Class#root' do
    #   it 'should return the toplevel node' do
    #     Category.root.name.should == "Electronics"
    #   end
    # end
    # 
    # describe 'Class#leaves' do
    #   it 'should return all nodes without descendants' do
    #     repository(:default) do
    #       Category.leaves.length.should == 6
    #     end
    #   end
    # end
    # 
    # describe '#ancestors' do
    #   it 'should return ancestors in an array' do
    #     repository(:default) do |repos|       
    #       Category.get(8).ancestors.map{|a|a.name}.should == ["Electronics","Portable Electronics","MP3 Players"]
    #     end
    #   end
    # end
    # 
    # describe '#children' do
    #   it 'should return children of node' do
    #     r = Category.root
    #     r.children.length.should == 2
    #     
    #     t = r.children.first
    #     t.children.length.should == 3
    #     t.children.first.name.should == "Tube"
    #     t.children[2].name.should == "Plasma"
    #   end
    # end
    # 
    # describe '#descendants and #self_and_descendants' do
    #   it 'should return all subnodes of node' do
    #     repository(:default) do
    #       r = Category.root
    #       r.self_and_descendants.length.should == 10
    #       r.descendants.length.should == 9
    #       
    #       t = r.children[1]
    #       t.descendants.length.should == 4
    #       t.descendants.map{|a|a.name}.should == ["MP3 Players","Flash","CD Players","2 Way Radios"]
    #     end
    #   end
    # end
    # 
    # describe '#leaves' do
    #   it 'should return all subnodes of node without descendants' do
    #     repository(:default) do
    #       r = Category.root
    #       r.leaves.length.should == 6
    #       
    #       t = r.children[1]
    #       t.leaves.length.should == 3
    #     end
    #   end
    # end
    # 
    # describe '#move' do
    #   it 'should move an entity correctly into another one' do
    #     repository(:default) do |repos|
    #       
    #       cat1 = Category[3]
    #       cat2 = Category[5]
    #       
    #       [cat1.lft,cat1.rgt].should == [3,4]
    #       
    #       cat1.move! :into, cat2
    #                 
    #       [cat2.lft,cat2.rgt].should == [5,8]
    #       [cat1.lft,cat1.rgt].should == [6,7]
    #       
    #       cat2.descendants.length.should == 1
    #       
    #       cat3 = Category[7]
    #       [cat3.lft,cat3.rgt].should == [11,14]
    #       
    #       cat3.move! :into, cat1
    #       
    #       [cat3.lft,cat3.rgt].should == [7,10]
    #       
    #       cat4 = Category[10]
    #       cat4.move! :into, Category[1]
    #       
    #       [cat4.lft,cat4.rgt].should == [18,19]
    #     end
    #   end
    # end
    
  end # describe DataMapper::Is::NestedSet
end
