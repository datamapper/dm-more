require File.dirname(__FILE__) + '/sql/sqlite3'
require File.dirname(__FILE__) + '/sql/mysql'
require File.dirname(__FILE__) + '/sql/postgresql'

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
      @adapter.quote_table_name(table_name)
    end

    def column(name, type, opts = {})
      @columns << Column.new(@adapter, name, type, opts)
    end

    def to_sql
        "CREATE TABLE #{quoted_table_name} (#{@columns.map(&:to_sql).join(', ')})"
    end

    class Column
      attr_accessor :name, :type

      def initialize(adapter, name, type, opts = {})
        @adapter = adapter
        @name, @type = name.to_s, type.to_s
        @opts = opts
      end

      def to_sql
          "#{quoted_name} #{type}"
      end

      def quoted_name
        @adapter.quote_column_name(name)
      end
    end

  end

  class TableModifier
    attr_accessor :table_name, :opts, :statements

    def initialize(*args)
      @adapter = adapter
      @table_name = table_name.to_s
      @opts = opts

      @statements = []

      self.instance_eval &block
    end

    def add_column(name, type, opts = {})
      @statements << "ALTER TABLE #{quoted_table_name} ADD COLUMN #{quote_column_name(name)} #{type.to_s}"
    end

    def drop_column(name)
      # raise NotImplemented for SQLite3. Can't ALTER TABLE, need to copy table. 
      # We'd have to inspect it, and we can't, since we aren't executing any queries yet.
      # Just write the sql yourself.
      if name.is_a?(Array)
        name.each{ |n| drop_column(n) }
      else
        @statements << "ALTER TABLE #{quoted_table_name} DROP COLUMN #{quote_column_name(name)}"
      end
    end
    alias drop_columns drop_column

    def rename_column(name, new_name, opts = {})
      # raise NotImplemented for SQLite3
      @statements << "ALTER TABLE #{quoted_table_name} RENAME COLUMN #{quote_column_name(name)} TO #{quote_column_name(new_name)}"
    end

    def change_column(name, type, opts = {})
      # raise NotImplemented for SQLite3
      @statements << "ALTER TABLE #{quoted_table_name} ALTER COLUMN #{quote_column_name(name)} TYPE #{type}"
    end

    def quote_column_name(name)
      @adapter.quote_column_name(name.to_s)
    end

    def quoted_table_name
      @adapter.quote_table_name(table_name)
    end

  end


end
