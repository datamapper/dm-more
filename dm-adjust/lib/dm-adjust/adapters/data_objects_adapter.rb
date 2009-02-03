module DataMapper
  module Adapters
    class DataObjectsAdapter < AbstractAdapter
      def adjust(attributes, query)
        statement = adjust_statement(attributes.keys, query)
        bind_values = attributes.values + query.bind_values
        execute(statement, *bind_values)
      end

      module SQL
        private

        def adjust_statement(properties, query)
          repository = query.repository
          
          qualify = query.links.any?

          statement = "UPDATE #{quote_name(query.model.storage_name(repository.name))}"
          statement << " SET #{set_adjustment_statement(repository, properties)}"
          statement << " WHERE #{where_statement(query.conditions, qualify)}" if query.conditions.any?
          statement
        rescue => e
           DataMapper.logger.error("QUERY INVALID: #{query.inspect} (#{e})")
           raise e
        end

        def set_adjustment_statement(repository, properties)
          properties.map { |p| [quote_name(p.field)] * 2 * " = " + " + (?)" } * ", "
        end

      end # module SQL

      include SQL
    end # class DataObjectsAdapter
  end # module Adapters
end # module DataMapper
