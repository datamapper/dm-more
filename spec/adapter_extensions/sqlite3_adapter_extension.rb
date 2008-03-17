require File.dirname(__FILE__) + '/../spec_helper'
require  File.dirname(__FILE__) + '/../../lib/adapter_extensions/sqlite3_adapter_extension'

describe AdapterExtensions::Sqlite3AdapterExtension do

  before do
    @adapter = DataMapper.repository(:default).adapter
    @adapter.execute "CREATE TABLE users (id INTEGER PRIMARY KEY, name TEXT)"
  end

  it "should find a table" do
    result = @adapter.table('users')
    result.should be_kind_of(Struct)
    result.name.should == 'users'
  end

  it "should be nil if table does not exist" do
    result = @adapter.table('no_table')
    result.should be_nil
  end

  after do
    @adapter.execute "DROP TABLE users"
  end
end
