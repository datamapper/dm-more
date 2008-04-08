require File.dirname(__FILE__) + '/../lib/migration_runner'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/migration_test.db")
DataMapper::Logger.new(STDOUT, :debug)
DataMapper.logger.debug( "Starting Migration" )

migration 1, :create_people_table do
  up do
    create_table :people do 
      column :id,     :int, :primary_key => true
      column :name,   :string
      column :age,    :int
    end
  end
  down do
    drop_table :people
  end
end

