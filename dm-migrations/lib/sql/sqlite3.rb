require File.dirname(__FILE__) + '/table'

module SQL
  module Sqlite3
    
    def supports_schema_transactions?
      true
    end
    
    def table(table_name)
      SQL::Table.new(self, table_name)
    end

    class Table < SQL::Table
      def initialize(adapter, table_name)
        @columns = []
        adapter.query_table(table_name).each do |col_struct|
          @columns << SQL::Sqlite3::Column.new(col_struct)
        end      
      end
    end

    class Column < SQL::Column
      def initialize(col_struct)
        @name, @type, @default_value, @primary_key = col_struct.name, col_struct.type, col_struct.dflt_value, col_struct.pk

        @not_null = col_struct.notnull == 0
      end
    end


  end
end
