require File.dirname(__FILE__) + '/table'

module SQL
  module Mysql

    def supports_schema_transactions?
      false
    end

    def table(table_name)
      SQL::Mysql::Table.new(self, table_name)
    end

    class Table
      def initialize(adapter, table_name)
        @columns = []
        adapter.query_table(table_name).each do |col_struct|
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
