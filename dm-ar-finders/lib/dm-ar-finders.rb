require 'rubygems'
gem 'dm-core', '0.10.0'
require 'dm-core'

module DataMapper
  module Model
    def find_or_create(search_attributes, create_attributes = {})
      first(search_attributes) || create(search_attributes.merge(create_attributes))
    end

    private

    def method_missing_with_find_by(method, *args, &block)
      if match = matches_dynamic_finder?(method)
        finder = determine_finder(match)
        attribute_names = extract_attribute_names_from_match(match)

        conditions = {}
        attribute_names.each {|key| conditions[key] = args.shift}

        send(finder, conditions)
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
    sql = nil
    query = nil
    bind_values = []
    properties = nil
    do_reload = false
    repository_name = default_repository_name
    args.each do |arg|
      if arg.kind_of?(String)
        sql = arg
      elsif arg.kind_of?(Array)
        sql = arg.first
        bind_values = arg[1..-1]
      elsif arg.kind_of?(Query)
        query = arg
      elsif arg.kind_of?(Hash)
        repository_name = arg.delete(:repository) if arg.include?(:repository)
        properties = Array(arg.delete(:properties)) if arg.include?(:properties)
        do_reload = arg.delete(:reload) if arg.include?(:reload)
        raise "unknown options to #find_by_sql: #{arg.inspect}" unless arg.empty?
      end
    end

    repository = repository(repository_name)
    raise "#find_by_sql only available for Repositories served by a DataObjectsAdapter" unless repository.adapter.kind_of?(Adapters::DataObjectsAdapter)

    if query
      sql = repository.adapter.send(:select_statement, query)
      bind_values = query.bind_values
    end

    raise "#find_by_sql requires a query of some kind to work" unless sql

    properties ||= self.properties(repository.name)

    Collection.new(Query.new(repository, self)) do |collection|
      repository.adapter.send(:with_connection) do |connection|
        command = connection.create_command(sql)

        begin
          reader = command.execute_reader(*bind_values)

          while(reader.next!)
            collection.load(reader.values)
          end
        ensure
          reader.close if reader
        end
      end
    end
  end
end # module Model
