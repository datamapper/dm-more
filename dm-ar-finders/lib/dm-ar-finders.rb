module DataMapper
  module Model
    #
    # Find instances by manually providing SQL
    #
    # @param sql<String>   an SQL query to execute
    # @param <Array>    an Array containing a String (being the SQL query to
    #   execute) and the parameters to the query.
    #   example: ["SELECT name FROM users WHERE id = ?", id]
    # @param query<Query>  a prepared Query to execute.
    # @param opts<Hash>     an options hash.
    #     :repository<Symbol> the name of the repository to execute the query
    #       in. Defaults to self.default_repository_name.
    #     :reload<Boolean>   whether to reload any instances found that already
    #      exist in the identity map. Defaults to false.
    #     :properties<Array>  the Properties of the instance that the query
    #       loads. Must contain Property objects.
    #       Defaults to self.properties.
    #
    # @return <Collection> the instance matched by the query.
    #
    # @example
    #   MyClass.find_by_sql(["SELECT id FROM my_classes WHERE county = ?",
    #     selected_county], :properties => MyClass.property[:id],
    #     :repository => :county_repo)
    #
    # @api public
    def find_by_sql(*args)
      sql             = nil
      query           = nil
      bind_values     = []
      properties      = self.properties(repository.name)
      reload          = false
      repository_name = default_repository_name

      args.each do |arg|
        case arg
          when String
            sql = arg
          when Array
            sql, *bind_values = args
          when Query
            query = arg
          when Hash
            repository_name = arg.delete(:repository)
            properties      = Array(arg.delete(:properties))
            reload          = arg.delete(:reload)
            raise "unknown options to #find_by_sql: #{arg.inspect}" unless arg.empty?
          else
            raise ArgumentError, "Unknown argument type: #{arg.class} (#{arg.inspect})"
        end
      end

      repository = repository(repository_name)

      unless repository.adapter.kind_of?(Adapters::DataObjectsAdapter)
        raise '#find_by_sql only available for Repositories served by a DataObjectsAdapter'
      end

      if query
        sql         = repository.adapter.send(:select_statement, query)
        bind_values = query.bind_values
      end

      raise '#find_by_sql requires a query of some kind to work' unless sql

      records = []

      repository.adapter.send(:with_connection) do |connection|
        reader = connection.create_command(sql).execute_reader(*bind_values)
        fields = properties.values_at(*reader.fields).compact

        begin
          while reader.next!
            records << fields.zip(reader.values).to_hash
          end
        ensure
          reader.close
        end
      end

      query = Query.new(repository, self, :fields => properties, :reload => reload)

      Collection.new(query, query.model.load(records, query))
    end

    alias find_or_create     first_or_create
    alias find_or_initialize first_or_new

    private

    def method_missing_with_find_by(method, *args, &block)
      if match = matches_dynamic_finder?(method)
        finder          = determine_finder(match)
        attribute_names = extract_attribute_names_from_match(match)

        send(finder, attribute_names.zip(args).to_hash)
      else
        method_missing_without_find_by(method, *args, &block)
      end
    end

    alias_method :method_missing_without_find_by, :method_missing
    alias_method :method_missing, :method_missing_with_find_by

    def matches_dynamic_finder?(method_id)
      /^find_(all_by|by)_([_a-zA-Z]\w*)$/.match(method_id.to_s)
    end

    def determine_finder(match)
      match.captures.first == 'all_by' ? :all : :first
    end

    def extract_attribute_names_from_match(match)
      match.captures.last.split('_and_')
    end
  end
end # module Model
