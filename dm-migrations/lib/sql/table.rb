require File.dirname(__FILE__) + '/column'

module SQL

  class Table

    attr_accessor :name, :columns

    def initialize(adapter, table_name)
      @columns = []
      adapter.query_table(table_name).each do |col_struct|
        @columns << SQL::Column.new(col_struct)
      end      
    end

    def to_s
      name
    end

    def column(column_name)
      @columns.select { |c| c.name == column_name.to_s }.first
    end

  end

end
