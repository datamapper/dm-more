require 'dm-migrations/sql/table'

module SQL
  module Mysql

    def supports_schema_transactions?
      false
    end

    def table(table_name)
      SQL::Mysql::Table.new(self, table_name)
    end

    def recreate_database
      execute "DROP DATABASE #{db_name}"
      execute "CREATE DATABASE #{db_name}"
      execute "USE #{db_name}"
    end

    def supports_serial?
      true
    end

    def table_options
      " ENGINE = InnoDB CHARACTER SET #{character_set} COLLATE #{collation}"
    end

    def property_schema_statement(connection, schema)
      if supports_serial? && schema[:serial]
        statement = "#{schema[:quote_column_name]} SERIAL PRIMARY KEY"
      else
        super
      end
    end

    class Table
      def initialize(adapter, table_name)
        @columns = []
        adapter.table_info(table_name).each do |col_struct|
          @columns << SQL::Mysql::Column.new(col_struct)
        end
      end
    end

    class Column
      def initialize(col_struct)
        @name, @type, @default_value, @primary_key = col_struct.name, col_struct.type, col_struct.dflt_value, col_struct.pk

        @not_null = col_struct.notnull == 0
      end
    end
  end
end
