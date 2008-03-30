require 'data_mapper/adapters/sqlite3_adapter'

module AdapterExtensions
  module Sqlite3AdapterExtension

    def table(tablename)
      query("SELECT * FROM sqlite_master 
             WHERE name='#{tablename}' AND type = 'table'").first
    end

  end
end

DataMapper::Adapters::Sqlite3Adapter.send(:include, AdapterExtensions::Sqlite3AdapterExtension)
