require 'benchmark'
require 'datamapper'

module DataMapper
  class DuplicateMigrationNameError < StandardError
    def initialize(migration)
      super("Duplicate Migration Name: '#{migration.name}', version: #{migration.position}")
    end
  end

  class Migration 

    attr_accessor :position, :name

    def initialize( position, name, opts = {}, &block )
      @position, @name = position, name
      @options = opts

      @database = DataMapper.repository(@options[:database] || :default)
      @adapter = @database.adapter

      @verbose = @options.has_key?(:verbose) ? @options[:verbose] : true

      @up_action   = lambda {}
      @down_action = lambda {}

      instance_eval &block
    end

    # define the actions that should be performed on an up migration
    def up(&block)
      @up_action = block
    end

    # define the actions that should be performed on a down migration
    def down(&block)
      @down_action = block
    end

    # perform the migration by running the code in the #up block
    def perform_up
      res = nil
      if needs_up?
        # DataMapper.database.adapter.transaction do 
        say_with_time "== Performing Up Migration ##{position}: #{name}", 0 do
          res = @up_action.call
        end
        update_migration_info(:up)
        # end
      end
      res
    end

    # un-do the migration by running the code in the #down block
    def perform_down
      res = nil
      if needs_down?
        # DataMapper.database.adapter.transaction do 
        say_with_time "== Performing Down Migration ##{position}: #{name}", 0 do
          res = @down_action.call
        end
        update_migration_info(:down)
        # end
      end
      res
    end

    # execute raw SQL
    def execute(sql)
      say_with_time(sql) do
        DataMapper.database(@options[:database] || :default) do
          DataMapper::database.execute(sql)
        end
      end
    end

    def create_table(table_name, opts = {}, &block)
      execute TableCreator.new(@adapter, table_name, opts, &block).to_sql
    end

    def drop_table(table_name, opts = {})
      execute "DROP TABLE #{@adapter.quote_table_name(table_name.to_s)}"
    end

    def modify_table(table_name, opts = {}, &block)
      TableModifier.new(@adapter, table_name, opts, &block).statements.each do |sql|
        execute(sql)
      end
    end

    # Orders migrations by position, so we know what order to run them in. 
    # First order by postition, then by name, so at least the order is predictable.
    def <=> other
      if self.position == other.position
        self.name.to_s <=> other.name.to_s
      else
        self.position <=> other.position
      end
    end

    # Output some text. Optional indent level
    def say(message, indent = 4)
      write "#{" " * indent} #{message}"
    end

    # Time how long the block takes to run, and output it with the message.
    def say_with_time(message, indent = 2)
      say(message, indent)
      result = nil
      time = Benchmark.measure { result = yield }
      say("-> %.4fs" % time.real, indent)
      result
    end

    # output the given text, but only if verbose mode is on
    def write(text="")
      puts text if @verbose
    end

    protected

    # Inserts or removes a row into the `migration_info` table, so we can mark this migration as run, or un-done
    def update_migration_info(direction)
      save, @verbose = @verbose, false

      create_migration_info_table_if_needed

      if direction.to_sym == :up
        execute("INSERT INTO #{migration_info_table} (#{migration_name_column}) VALUES (#{quoted_name})")
      elsif direction.to_sym == :down
        execute("DELETE FROM #{migration_info_table} WHERE #{migration_name_column} = #{quoted_name}")
      end
      @verbose = save
    end

    def create_migration_info_table_if_needed
      save, @verbose = @verbose, false
      unless migration_info_table_exists?
        execute("CREATE TABLE #{migration_info_table} (#{migration_name_column} varchar)")
      end
      @verbose = save
    end

    # Quote the name of the migration for use in SQL
    def quoted_name
      "'#{name}'"
    end

    def migration_info_table_exists?
      DataMapper::database.adapter.table('migration_info').exists?
    end

    # Fetch the record for this migration out of the migration_info table
    def migration_record
      return [] unless migration_info_table_exists?
      DataMapper::database.query("SELECT #{migration_name_column} FROM #{migration_info_table} WHERE #{migration_name_column} = #{quoted_name}")
    end

    # True if the migration needs to be run
    def needs_up?
      create_migration_info_table_if_needed
      migration_record.empty?
    end

    # True if the migration has already been run
    def needs_down?
      create_migration_info_table_if_needed
      ! migration_record.empty?
    end

    # Quoted table name, for the adapter
    def migration_info_table
      @migration_info_table ||= @adapter.quote_table_name("migration_info")
    end

    # Quoted `migration_name` column, for the adapter
    def migration_name_column
      @migration_name_column ||= @adapter.quote_column_name("migration_name")
    end

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
          return
        end

        @statements << "ALTER TABLE #{quoted_table_name} DROP COLUMN #{quote_column_name(name)}"
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
end


