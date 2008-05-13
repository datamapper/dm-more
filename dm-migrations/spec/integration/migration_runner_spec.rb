require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

if HAS_SQLITE3 || HAS_MYSQL || HAS_POSTGRES
  describe 'migration runner', '#migration' do
    it 'should create a new migration object, and add it to the list of migrations' do
      migration( 1, :create_people_table) { }

      @@migrations.should be_kind_of(Array)
      @@migrations.should have(1).item
      @@migrations.first.name.should == "create_people_table"
    end
  end
end
