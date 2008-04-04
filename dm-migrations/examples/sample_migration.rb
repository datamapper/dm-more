require File.dirname(__FILE__) + '/../lib/migration_runner'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/migration_test.db")

migration 1, :create_people_table do
  up do
    create_table :people do 
      column :name,   :string
      column :age,    :int
    end
  end
  down do
    drop_table :people
  end
end

