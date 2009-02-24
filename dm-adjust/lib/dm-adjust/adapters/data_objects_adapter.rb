module DataMapper
  module Adapters
    class DataObjectsAdapter < AbstractAdapter
      def adjust(attributes, query)
        # TODO: if the query contains any links, a limit or an offset
        # use a subselect to get the rows to be updated

        properties  = []
        bind_values = []

        # make the order of the properties consistent
        query.model.properties(name).each do |property|
          next unless attributes.key?(property)
          properties  << property
          bind_values << attributes[property]
        end

        statement, conditions_bind_values = adjust_statement(properties, query)

        bind_values.concat(conditions_bind_values)

        execute(statement, *bind_values)
      end

      module SQL
        private

        def adjust_statement(properties, query)
          where_statement, bind_values = where_statement(query.conditions)

          statement = "UPDATE #{quote_name(query.model.storage_name(name))}"
          statement << " SET #{set_adjustment_statement(properties)}"
          statement << " WHERE #{where_statement}" unless where_statement.blank?

          return statement, bind_values
        end

        def set_adjustment_statement(properties)
          properties.map { |p| "#{quote_name(p.field)} = #{quote_name(p.field)} + ?" }.join(', ')
        end

      end # module SQL

      include SQL
    end # class DataObjectsAdapter
  end # module Adapters
end # module DataMapper
