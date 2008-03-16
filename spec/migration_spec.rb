#require File.dirname(__FILE__) + '/spec_helper'
require File.dirname(__FILE__) + '/../lib/migration'

describe DataMapper::Migration, 'interface' do
  before do
    @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) { }
  end

  it "should have a postition attribute" do
    @migration.should respond_to(:position)
    @migration.should respond_to(:position=)
    @migration.position.should == 1
  end

  it "should have a name attribute" do
    @migration.should respond_to(:name)
    @migration.should respond_to(:name=)
    @migration.name.should == :create_people_table
  end

  it "should have a :database option" do
    m = DataMapper::Migration.new(2, :create_dogs_table, :database => :other) {}
    m.instance_variable_get(:@database).adapter.name.should == :other
  end

  it "should use the default database by default" do
    @migration.instance_variable_get(:@database).adapter.name.should == :default
  end

  it "should have a verbose option" do
    m = DataMapper::Migration.new(2, :create_dogs_table, :verbose => false) {}
    m.instance_variable_get(:@verbose).should == false
  end 

  it "should be verbose by default" do
    m = DataMapper::Migration.new(2, :create_dogs_table) {}
    m.instance_variable_get(:@verbose).should == true
  end

  it "should be sortable, first by position, then name" do
    m1 = DataMapper::Migration.new(1, :create_people_table) {}
    m2 = DataMapper::Migration.new(2, :create_dogs_table) {}
    m3 = DataMapper::Migration.new(2, :create_cats_table) {}
    m4 = DataMapper::Migration.new(4, :create_birds_table) {}

    [m1, m2, m3, m4].sort.should == [m1, m3, m2, m4]
  end
end

describe DataMapper::Migration, 'defining actions' do
  before do
    @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) { }
  end

  it "should have an #up method" do
    @migration.should respond_to(:up)
  end

  it "should save the block passed into the #up method in @up_action" do
    action = lambda {}
    @migration.up(&action)

    @migration.instance_variable_get(:@up_action).should == action
  end

  it "should have a #down method" do
    @migration.should respond_to(:down)
  end

  it "should save the block passed into the #down method in @down_action" do
    action = lambda {}
    @migration.down(&action)

    @migration.instance_variable_get(:@down_action).should == action
  end

  it "should make available an #execute method" do
    @migration.should respond_to(:execute)
  end

  it "should run the sql passed into the #execute method"
  # TODO: Find out how to stub the DataMapper::database.execute method
end

describe DataMapper::Migration, "output" do
  before do
    @migration = DataMapper::Migration.new(1, :create_people_table) { }
    @migration.stub!(:write) # so that we don't actually write anything to the console!
  end

  it "should #say a string with an indent" do
    @migration.should_receive(:write).with("   Foobar")
    @migration.say("Foobar", 2)
  end

  it "should #say with a default indent of 4" do
    @migration.should_receive(:write).with("     Foobar")
    @migration.say("Foobar")
  end

  it "should #say_with_time the running time of a block" do
    @migration.should_receive(:write).with(/Block/)
    @migration.should_receive(:write).with(/-> [\d]+/)

    @migration.say_with_time("Block"){ }
  end

end

describe DataMapper::Migration, "#create_table helper" do
  before do
    @creator = DataMapper::Migration::TableCreator.new(database.adapter, :people) do
                  column :name, :string
               end
  end

  it "should have a #create_table helper" do
    @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) { }
    @migration.should respond_to(:create_table)
  end

  it "should have a table_name" do
    @creator.table_name.should == "people"
  end

  it "should have an adapter" do
    @creator.instance_eval("@adapter").should == database.adapter
  end

  it "should have an options hash" do
    @creator.opts.should be_kind_of(Hash)
    @creator.opts.should == {}
  end

  it "should have an array of columns" do
    @creator.instance_eval("@columns").should be_kind_of(Array)
    @creator.instance_eval("@columns").should have(1).item
    @creator.instance_eval("@columns").first.should be_kind_of(DataMapper::Migration::TableCreator::Column)
  end

  it "should quote the table name for the adapter" do
    @creator.quoted_table_name.should == '"people"'
  end



end

describe DataMapper::Migration, "#modify_table helper" do
  before do
    @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) { }
  end

  it "should have a #modify_table helper" do
    @migration.should respond_to(:modify_table)
  end

end

describe DataMapper::Migration, "other helpers" do
  before do
    @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) { }
  end

  it "should have a #drop_table helper" do
    @migration.should respond_to(:drop_table)
  end

end

describe DataMapper::Migration, "version tracking" do
  before do
    @migration = DataMapper::Migration.new(1, :create_people_table, :verbose => false) do
      up   { :ran_up }
      down { :ran_down }
    end

    @migration.send(:create_migration_info_table_if_needed)
  end

  def insert_migration_record
    database.execute("INSERT INTO migration_info (migration_name) VALUES ('create_people_table')")
  end

  it "should know if the migration_info table exists" do
    @migration.send(:migration_info_table_exists?).should be_true
  end

  it "should know if the migration_info table does not exist" do
    database.execute("DROP TABLE migration_info") rescue nil
    @migration.send(:migration_info_table_exists?).should be_false
  end

  it "should be able to find the migration_info record for itself" do
    insert_migration_record
    @migration.send(:migration_record).should_not be_empty
  end

  it "should know if a migration needs_up?" do
    @migration.send(:needs_up?).should be_true
    insert_migration_record
    @migration.send(:needs_up?).should be_false
  end

  it "should know if a migration needs_down?" do
    @migration.send(:needs_down?).should be_false
    insert_migration_record
    @migration.send(:needs_down?).should be_true
  end

  it "should properly quote the migration_info table for use in queries" do
    @migration.send(:migration_info_table).should == database.adapter.quote_table_name('migration_info')
  end

  it "should properly quote the migration_info.migration_name column for use in queries" do
    @migration.send(:migration_name_column).should == database.adapter.quote_column_name('migration_name')
  end 

  it "should properly quote the migration's name for use in queries"
  # TODO how to i call the adapter's #escape_sql method?

  it "should create the migration_info table if it doesn't exist" do
    database.execute("DROP TABLE migration_info") rescue nil
    @migration.send(:migration_info_table_exists?).should be_false
    @migration.send(:create_migration_info_table_if_needed)
    @migration.send(:migration_info_table_exists?).should be_true
  end

  it "should insert a record into the migration_info table on up" do
    @migration.send(:migration_record).should be_empty
    @migration.perform_up.should == :ran_up
    @migration.send(:migration_record).should_not be_empty
  end

  it "should remove a record from the migration_info table on down" do
    insert_migration_record
    @migration.send(:migration_record).should_not be_empty
    @migration.perform_down.should == :ran_down
    @migration.send(:migration_record).should be_empty
  end

  it "should not run the up action if the record exists in the table" do
    insert_migration_record
    @migration.perform_up.should_not == :ran_up
  end

  it "should not run the down action if the record does not exist in the table" do
    @migration.perform_down.should_not == :ran_down
  end

  after do
    database.execute("DROP TABLE migration_info") rescue nil
  end
end
