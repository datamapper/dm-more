require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe '.adjust' do
    before :all do
      # A simplistic example, using with an Integer property
      class Person
        include DataMapper::Resource
        property :id, Integer, :serial => true
        property :name, String
        property :salary, Integer, :default => 20000
        property :age, Integer
        
        auto_migrate!(:default)
      end

      Person.create(:name => 'George', :age => 15)
      Person.create(:name => 'Puff',   :age => 18)
      Person.create(:name => 'Danny',  :age => 26)
      Person.create(:name => 'Selma',  :age => 28)
      Person.create(:name => 'John',   :age => 49)
      Person.create(:name => 'Amadeus',:age => 60)

    end
    
    describe 'DataMapper::Resource.adjust' do
    
      it 'should adjust values' do
        repository(:default) do
          p = Person.get(1)
          p.salary.should == 20000
          Person.adjust(:salary => 1000)  
          Person.all.each{|p| p.salary.should == 21000}
        end
      end
    
    end
    
    describe 'DataMapper::Collection.adjust' do
    
      it 'should adjust values' do
        repository(:default) do |repos|
          @oldies = Person.all(:age.gte => 40)
          @oldies.adjust(:salary => 5000)
          @oldies.each{|p| p.salary.should == 25000}
          
          Person.get(1).salary.should == 20000
          
          @children = Person.all(:age.lte => 18)
          @children.adjust(:salary => -10000)
          @children.each{|p| p.salary.should == 10000}
        end
      end
      
      it 'should load the query if conditions were adjusted' do
        repository(:default) do |repos|
          @specific = Person.all(:salary => 25000)
          #@specific.length.should == 2
          @specific.adjust(:salary => 5000)
          @specific.length.should == 2
        end
      end

    end

  end
end
