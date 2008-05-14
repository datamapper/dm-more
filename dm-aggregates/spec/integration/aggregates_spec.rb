require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'DataMapper::Resource' do
    before :all do
      class Dragon
        include DataMapper::Resource
        property :id, Integer, :serial => true
        property :name, String
        property :is_fire_breathing, TrueClass
        property :toes_on_claw, Integer

        auto_migrate!(:default)
      end

      Dragon.create(:name => 'George', :is_fire_breathing => false, :toes_on_claw => 3)
      Dragon.create(:name => 'Puff',   :is_fire_breathing => true,  :toes_on_claw => 4)
      Dragon.create(:name => nil,      :is_fire_breathing => true,  :toes_on_claw => 5)
    end

    describe '.count' do
      describe 'with no arguments' do
        it 'should count the results' do
          Dragon.count.should == 3
        end

        it 'should count the results with conditions having operators' do
          Dragon.count(:toes_on_claw.gt => 3).should == 2
        end

        it 'should count the results with raw conditions' do
          statement = 'is_fire_breathing = ?'
          Dragon.count(:conditions => [ statement, false ]).should == 1
          Dragon.count(:conditions => [ statement, true  ]).should == 2
        end
      end

      describe 'with a property name' do
        before do
          @property_name = :name
        end

        it 'should count the results where the property is not nil' do
          Dragon.count(@property_name).should == 2
        end

        it 'should count the results with conditions having operators where the property is not nil' do
          result = Dragon.count(@property_name, :toes_on_claw.gt => 3)
          result.should == 1
        end

        it 'should count the results with raw conditions where the property is not nil' do
          statement = 'is_fire_breathing = ?'
          Dragon.count(@property_name, :conditions => [ statement, false ]).should == 1
          Dragon.count(@property_name, :conditions => [ statement, true  ]).should == 1
        end
      end
    end

    describe '.min' do
      describe 'with a property name' do
        it 'should provide the min' do
          Dragon.min(:toes_on_claw).should == 3
        end
      end
      describe 'with no arguments' do
        it 'should raise an error' do
          #Dragon.min
          pending
        end
      end
    end

    describe '.max' do
      describe 'with a property name' do
        it 'should provide the max' do
          Dragon.max(:toes_on_claw).should == 5
        end
      end
    end

    describe '.avg' do
      describe 'with a property name' do
        it 'should provide the avg' do
          Dragon.avg(:toes_on_claw).should == 4
        end
      end
    end

    describe '.sum' do
      describe 'with a property name' do
        it 'should provide the sum' do
          Dragon.sum(:toes_on_claw).should == 12
        end
      end
    end

  end
end
