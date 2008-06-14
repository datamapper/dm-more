require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'migration runner', '#migration' do
    before(:each) do
      migration( 1, :create_people_table) { }
    end

    it 'should create a new migration object, and add it to the list of migrations' do
      @@migrations.should be_kind_of(Array)
      @@migrations.should have(1).item
      @@migrations.first.name.should == "create_people_table"
    end

    it 'should allow multiple migrations to be added' do
      migration( 2, :add_dob_to_people) { }
      migration( 2, :add_favorite_pet_to_people) { }
      migration( 3, :add_something_else_to_people) { }
      @@migrations.should have(4).items
    end

    it 'should raise an error on adding with a duplicated name' do
      lambda { migration( 1, :create_people_table) { } }.should raise_error(RuntimeError, /Migration name conflict/)
    end

    after(:each) do
      @@migrations = []
    end
  end
end
