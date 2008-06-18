require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Is::List' do
    before :all do
      class Todo
        include DataMapper::Resource
        include DataMapper::Is::List

        property :id, Integer, :serial => true
        property :title, String
        
        is_a_list
      end
      
      Todo.auto_migrate!(:default)
      
      Todo.create!(:title => "Write down what is needed in a list-plugin")
      Todo.create!(:title => "Complete a temporary version of is-list")
      Todo.create!(:title => "Squash bugs in nested-set")
      Todo.create!(:title => "Eat tasty cupcake")
      Todo.create!(:title => "Procrastinate on paid work")
      Todo.create!(:title => "Go to sleep")
      
    end
    
    describe 'automatic positioning' do
      it 'should get the shadow variable of the last position' do
        repository(:default) do |repos|
          Todo[3].position=8
          Todo[3].dirty?.should == true
          Todo[3].attribute_dirty?(:position).should == true
          Todo[3].shadow_attribute_get(:position).should == 3
        end
      end
      
      it 'should insert items into the list automatically' do
        repository(:default) do |repos|
          Todo[3].position.should == 3
          Todo[6].position.should == 6
        end
      end
    end
    
    describe 'movement' do
      it 'should rearrange items correctly when moving :higher' do
        repository(:default) do |repos|
          Todo[3].move :higher
          Todo[3].position.should == 2
          Todo[2].position.should == 3
          Todo[4].position.should == 4
        end
      end
      
      it 'should rearrange items correctly when moving :lower' do
        repository(:default) do |repos|
          Todo[3].position.should == 2
          Todo[2].position.should == 3
          Todo[3].move :lower
          Todo[3].position.should == 3
          Todo[2].position.should == 2
          Todo[4].position.should == 4
        end
      end
      
      it 'should rearrange items correctly when moving :highest or :lowest' do
        repository(:default) do |repos|
          Todo[1].position.should == 1
          Todo[1].move(:lowest)
          Todo[1].position.should == 6
          Todo[6].position.should == 5
          Todo[6].move(:highest)
          Todo[6].position.should == 1
          Todo[5].position.should == 5
        end
      end
      
      it 'should not rearrange when trying to move top-item up, or bottom item down' do
        repository(:default) do |repos|
          Todo[6].position.should == 1
          Todo[2].position.should == 2
          Todo[6].move(:higher).should == false
          Todo[6].position.should == 1
          Todo[1].position.should == 6
          Todo[1].move(:lower).should == false
        end
      end
      
      it 'should rearrange items correctly when moving :above or :below' do
        repository(:default) do |repos|
          Todo[6].position.should == 1
          Todo[5].position.should == 5
          Todo[6].move(:below => Todo[5])
          Todo[6].position
        end
      end
      
    end

  end
end
