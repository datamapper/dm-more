require File.dirname(__FILE__) + '/table'

module SQL
  module Sqlite3
    def table_exists?(table_name)
      query_table(table_name).size > 0
    end

    def supports_schema_transactions?
      true
    end

    def drop_database
      DataMapper.logger.info "Dropping #{@uri.path}"
      system "rm #{@uri.path}"
    end

    def create_database
      # do nothing, sqlite will automatically create the database file
    end

    def table(table_name)
      SQL::Table.new(self, table_name)
    end

    def query_table(table_name)
      query("PRAGMA table_info('#{table_name}')")
    end

  end
end
