require File.dirname(__FILE__) + '/../lib/migration_runner'

#DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/migration_test.db")
DataMapper.setup(:default, "postgres://localhost/migration_test")
# DataMapper.setup(:default, "mysql://localhost/migration_test")

DataMapper::Logger.new(STDOUT, :debug)
DataMapper.logger.debug( "Starting Migration" )

migration 1, :create_people_table do
  up do
    create_table :people do 
      column :id,     "integer"
      column :name,   "varchar(255)"
      column :age,    "integer"
    end
  end
  down do
    drop_table :people
  end
end

migration 2, :add_dob_to_people do
  up do
    modify_table :people do
      add_column :dob, "timestamp"
    end
  end

  down do
    modify_table :people do
      drop_column :dob
    end
  end    
end

if $0 == __FILE__
  if $*.first == "down"
    migrate_down!
  else
    migrate_up!
  end
end
  
