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
      @adapter.send(:quote_name, table_name)
    end

    def column(name, type, opts = {})
      @columns << Column.new(@adapter, name, type, opts)
    end

    def to_sql
      "CREATE TABLE #{quoted_table_name} (#{@columns.map{ |c| c.to_sql }.join(', ')})#{@adapter.table_options}"
    end

    # A helper for using the native NOW() SQL function in a default
    def now
      SqlExpr.new('NOW()')
    end

    # A helper for using the native UUID() SQL function in a default
    def uuid
      SqlExpr.new('UUID()')
    end

    class SqlExpr
      attr_accessor :sql
      def initialize(sql)
        @sql = sql
      end

      def to_s
        @sql.to_s
      end
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
        unless schema.has_key?(:nullable?)
          schema[:nullable?] = schema.has_key?(:nullable) ? schema[:nullable] : !schema[:not_null]
        end
        if type_class.is_a?(String)
          schema[:primitive] = type_class
        else
          primitive = type_class.respond_to?(:primitive) ? type_class.primitive : type_class
          schema = @adapter.class.type_map[primitive].merge(schema)
        end
        @adapter.send(:with_connection) do |connection|
          @adapter.property_schema_statement(connection, schema)
        end
      end

      def to_sql
        type
      end

      def quoted_name
        @adapter.send(:quote_name, name)
      end
    end

  end

end
