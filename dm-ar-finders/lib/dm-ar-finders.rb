module DataMapper
  module Model
    # Lookup the resource by the primary key
    #
    # @param [Integer] id
    #   the primary key value for the resource
    #
    # @return [Resource]
    #   the resource that was found
    # @return [nil]
    #   nil if no resource was found
    #
    # @api public
    def find(id)
      get(id)
    end

    # Find resources by providing your own SQL query or DataMapper::Query
    # instance.
    #
    # @param [Array] sql_or_query
    #   An array whose first element is an SQL query, and the other
    #   elements are bind values for the query.
    # @param [Hash] options
    #   A hash containing extra options.
    #
    # @overload find_by_sql(string_query, options = {})
    #   @param [String] sql_or_query
    #     A string containing an SQL query to execute.
    #   @param [Hash] options
    #     A hash containing extra options.
    #
    # @overload find_by_sql(dm_query, options = {})
    #   @param [DataMapper::Query] sql_or_query
    #     A DataMapper::Query instance to be used to generate an SQL query.
    #   @param [Hash] options
    #     A hash containing extra options.
    #
    # @option options [true, false] :reload (false)
    #   Whether to reload any matching resources which are already loaded.
    # @option options [Symbol, Array, DataMapper::Property, DataMapper::PropertySet] :properties
    #   Specific properties to be loaded. May be a single symbol, a Property
    #   instance, an array of Properties, or a PropertySet.
    # @option options [Symbol] :repository
    #   The repository to query. Uses the model default if none is specified.
    #
    # @return [DataMapper::Collection]
    #   A collection containing any records which matched your query.
    #
    # @raise [ArgumentError]
    #
    # @example Query with bind values
    #   MyClass.find_by_sql(["SELECT id FROM my_classes WHERE county = ?",
    #     selected_county])
    #
    # @example String query
    #   MyClass.find_by_sql("SELECT id FROM my_classes LIMIT 1")
    #
    # @example Query with properties option
    #   MyClass.find_by_sql("SELECT id FROM my_classes LIMIT 1",
    #     :properties => [:id, :name])
    #
    # @example Query with repository
    #   MyClass.find_by_sql(["SELECT id FROM my_classes WHERE county = ?",
    #     selected_county], :properties => MyClass.property[:name],
    #     :repository => :county_repo)
    #
    # @api public
    def find_by_sql(sql_or_query, options = {})
      # Figure out what the user passed in.
      case sql_or_query
      when Array
        sql, *bind_values = sql_or_query
      when String
        sql, bind_values = sql_or_query, []
      when DataMapper::Query
        sql, bind_values = repository.adapter.send(:select_statement, query)
      else
        raise ArgumentError, '#find_by_sql requires a query of some kind to work'
      end

      # Sort out the options.
      repository = repository(options.fetch(:repository, default_repository_name))

      if options.key?(:properties)
        if options[:properties].kind_of?(DataMapper::PropertySet)
          properties = Array(options[:properties])
        else
          # Normalize properties into PropertySet[Property].
          properties = Array(options[:properties]).map! do |prop|
            prop.kind_of?(Symbol) ? self.properties[prop] : prop
          end

          properties = DataMapper::PropertySet.new(properties)
        end
      else
        properties = self.properties(repository.name)
      end

      unless repository.adapter.kind_of?(Adapters::DataObjectsAdapter)
        raise '#find_by_sql only available for Repositories served by a DataObjectsAdapter'
      end

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

      query = Query.new(repository, self,
        :fields => properties, :reload => options.fetch(:reload, false))

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
