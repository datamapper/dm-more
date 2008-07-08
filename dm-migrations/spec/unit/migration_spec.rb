require 'pathname'
require Pathname(__FILE__).dirname + '../spec_helper'

require Pathname(__FILE__).dirname + '../../lib/migration'

describe 'Migration' do

  before do
    @adapter = mock('adapter', :class => DataMapper::Adapters::Sqlite3Adapter)
    @repo = mock('DataMapper.repository', :adapter => @adapter)
    DataMapper.stub!(:repository).and_return(@repo)
    @m = DataMapper::Migration.new(1, :do_nothing, {}) {}
    @m.stub!(:write) # silence any output
  end

  [:position, :name, :database, :adapter].each do |meth|
    it "should respond to ##{meth}" do
      @m.should respond_to(meth)
    end
  end

  describe 'initialization' do
    it 'should set @position from the given position' do
      @m.instance_variable_get(:@position).should == 1
    end

    it 'should set @name from the given name' do
      @m.instance_variable_get(:@name).should == :do_nothing
    end

    it 'should set @options from the options hash' do
      @m.instance_variable_get(:@options).should == {}
    end

    it 'should set @database from the default repository if no :database option is given' do
      DataMapper.should_receive(:repository).with(:default).and_return(@repo)
      DataMapper::Migration.new(1, :do_nothing, {}) {}
    end

    it 'should set @database to the repository specified with the :database option' do
      DataMapper.should_receive(:repository).with(:foobar).and_return(@repo)
      DataMapper::Migration.new(1, :do_nothing, :database => :foobar) {}
    end

    it 'should determine the class of the adapter to be extended' do
      @adapter.should_receive(:class).and_return(DataMapper::Adapters::Sqlite3Adapter)
      DataMapper::Migration.new(1, :do_nothing, {}) {}
    end
    
    it 'should extend the adapter with the right module' do
      @adapter.should_receive(:extend).with(SQL::Sqlite3)
      DataMapper::Migration.new(1, :do_nothing, {}) {}
    end

    it 'should raise "Unsupported adapter" on an unknown adapter' do
      @adapter.should_receive(:class).any_number_of_times.and_return("InvalidAdapter")
      lambda {
        DataMapper::Migration.new(1, :do_nothing, {}) {}
      }.should raise_error
    end

    it 'should set @verbose from the options hash' do
      m = DataMapper::Migration.new(1, :do_nothing, :verbose => false) {}
      m.instance_variable_get(:@verbose).should be_false
    end

    it 'should set @verbose to true by default' do 
      @m.instance_variable_get(:@verbose).should be_true
    end
  
    it 'should set the @up_action to an empty block' do
      @m.instance_variable_get(:@up_action).should be_kind_of(Proc)
    end

    it 'should set the @down_action to an empty block' do
      @m.instance_variable_get(:@down_action).should be_kind_of(Proc)
    end

    it 'should evaluate the given block'
      
  end

  it 'should set the @up_action when #up is called with a block' do
    action = lambda {}
    @m.up(&action)
    @m.instance_variable_get(:@up_action).should == action
  end

  it 'should set the @up_action when #up is called with a block' do
    action = lambda {}
    @m.down(&action)
    @m.instance_variable_get(:@down_action).should == action
  end

  describe 'perform_up' do
    before do
      @up_action = mock('proc', :call => true)
      @m.instance_variable_set(:@up_action, @up_action)
      @m.stub!(:needs_up?).and_return(true)
      @m.stub!(:update_migration_info)
    end

    it 'should call the action assigned to @up_action and return the result' do
      @up_action.should_receive(:call).and_return(:result)
      @m.perform_up.should == :result
    end

    it 'should output a status message with the position and name of the migration' do
      @m.should_receive(:write).with(/Performing Up Migration #1: do_nothing/)
      @m.perform_up
    end

    it 'should not run if it doesnt need to be' do
      @m.should_receive(:needs_up?).and_return(false)
      @up_action.should_not_receive(:call)
      @m.perform_up
    end

    it 'should update the migration info table' do
      @m.should_receive(:update_migration_info).with(:up)
      @m.perform_up
    end

    it 'should not update the migration info table if the migration does not need run' do
      @m.should_receive(:needs_up?).and_return(false)
      @m.should_not_receive(:update_migration_info)
      @m.perform_up
    end

  end

  describe 'perform_down' do
    before do
      @down_action = mock('proc', :call => true)
      @m.instance_variable_set(:@down_action, @down_action)
      @m.stub!(:needs_down?).and_return(true)
      @m.stub!(:update_migration_info)
    end

    it 'should call the action assigned to @down_action and return the result' do
      @down_action.should_receive(:call).and_return(:result)
      @m.perform_down.should == :result
    end

    it 'should output a status message with the position and name of the migration' do
      @m.should_receive(:write).with(/Performing Down Migration #1: do_nothing/)
      @m.perform_down
    end

    it 'should not run if it doesnt need to be' do
      @m.should_receive(:needs_down?).and_return(false)
      @down_action.should_not_receive(:call)
      @m.perform_down
    end

    it 'should update the migration info table' do
      @m.should_receive(:update_migration_info).with(:down)
      @m.perform_down
    end

    it 'should not update the migration info table if the migration does not need run' do
      @m.should_receive(:needs_down?).and_return(false)
      @m.should_not_receive(:update_migration_info)
      @m.perform_down
    end

  end

  describe 'methods used in the action blocks' do 

    describe '#execute' do
      before do
        @adapter.stub!(:execute)
      end

      it 'should send the SQL it its executing to the adapter execute method' do
        @adapter.should_receive(:execute).with('SELECT SOME SQL')
        @m.execute('SELECT SOME SQL')
      end

      it 'should output the SQL it is executing' do
        @m.should_receive(:write).with(/SELECT SOME SQL/)
        @m.execute('SELECT SOME SQL')
      end
    end

    describe 'helpers' do
      before do
        @m.stub!(:execute) # don't actually run anything
      end

      describe '#create_table' do
        before do
          @tc = mock('TableCreator', :to_sql => 'CREATE TABLE')
          SQL::TableCreator.stub!(:new).and_return(@tc)
        end

        it 'should create a new TableCreator object' do
          SQL::TableCreator.should_receive(:new).with(@adapter, :users, {}).and_return(@tc)
          @m.create_table(:users, {}) { }
        end
        
        it 'should convert the TableCreator object to an sql statement' do
          @tc.should_receive(:to_sql).and_return('CREATE TABLE')
          @m.create_table(:users, {}) { }
        end

        it 'should execute the create table sql' do
          @m.should_receive(:execute).with('CREATE TABLE')
          @m.create_table(:users, {}) { }
        end

      end

      describe '#drop_table' do
        it 'should quote the table name' do
          @adapter.should_receive(:quote_table_name).with('users')
          @m.drop_table :users
        end

        it 'should execute the DROP TABLE sql for the table' do
          @adapter.stub!(:quote_table_name).and_return("'users'")
          @m.should_receive(:execute).with(%{DROP TABLE 'users'})
          @m.drop_table :users
        end

      end

      describe '#modify_table' do

      end

    end

  end
end

