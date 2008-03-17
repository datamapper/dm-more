require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/migration_runner'

DataMapper.setup(:default, "sqlite3:///#{Dir.pwd}/migration_test.db")

describe 'migration runner', '#migration' do
  it 'should create a new migration object, and add it to the list of migrations' do
    migration( 1, :create_people_table) { }

    @migrations.should be_kind_of(Array)
    @migrations.should have(1).item
    @migrations.first.name.should == "create_people_table"
  end
end
