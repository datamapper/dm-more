module SQL
  class TableCreator
    attr_accessor :table_name, :opts

    def initialize(adapter, table_name, opts = {}, &block)
      @adapter = adapter
      @table_name = table_name.to_s
      @opts = opts

      @columns = []

      self.instance_eval &block
    end

    def quoted_table_name
      @adapter.send(:quote_table_name, table_name)
    end

    def column(name, type, opts = {})
      @columns << Column.new(@adapter, name, type, opts)
    end

    def to_sql
        "CREATE TABLE #{quoted_table_name} (#{@columns.map{ |c| c.to_sql }.join(', ')})"
    end

    class Column
      attr_accessor :name, :type

      def initialize(adapter, name, type, opts = {})
        @adapter = adapter
        @name = name.to_s
        @opts = opts
        @type = build_type(type)
      end

      def build_type(type_class)
        schema = {:name => @name, :quote_column_name => quoted_name}.merge(@opts)
        schema[:serial?] ||= schema[:serial]
        schema[:nullable?] ||= schema[:nullable]
        schema = @adapter.class.type_map[type_class].merge(schema)
        @adapter.property_schema_statement(schema)
      end

      def to_sql
          type
      end

      def quoted_name
        @adapter.send(:quote_column_name, name)
      end
    end

  end

end
