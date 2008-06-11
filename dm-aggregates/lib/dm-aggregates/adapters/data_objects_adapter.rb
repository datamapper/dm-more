module DataMapper
  module Adapters
    class DataObjectsAdapter
      def count(repository, property, query)
        bind_values = query.bind_values
        query(aggregate_read_statement(:count, property, query), *bind_values).first
      end

      def min(respository, property, query)
        bind_values = query.bind_values
        min = query(aggregate_read_statement(:min, property, query), *bind_values).first
        property.typecast(min)
      end

      def max(respository, property, query)
        bind_values = query.bind_values
        max = query(aggregate_read_statement(:max, property, query), *bind_values).first
        property.typecast(max)
      end

      def avg(respository, property, query)
        bind_values = query.bind_values
        avg = query(aggregate_read_statement(:avg, property, query), *bind_values).first
        property.type == Integer ? avg.to_f : property.typecast(avg)
      end

      def sum(respository, property, query)
        bind_values = query.bind_values
        sum = query(aggregate_read_statement(:sum, property, query), *bind_values).first
        property.typecast(sum)
      end

      module SQL
        private

        def aggregate_read_statement(aggregate_function, property, query)
          statement = "SELECT #{aggregate_field_statement(aggregate_function, property, query.links.any?)}"
          statement << " FROM #{quote_table_name(query.model.storage_name(name))}"
          statement << links_statement(query)                  if query.links.any?
          statement << " WHERE #{conditions_statement(query)}" if query.conditions.any?
          statement << " ORDER BY #{order_statement(query)}"   if query.order.any?
          statement << " LIMIT #{query.limit}"                 if query.limit
          statement << " OFFSET #{query.offset}"               if query.offset && query.offset > 0
          statement
        rescue => e
          DataMapper.logger.error("QUERY INVALID: #{query.inspect} (#{e})")
          raise e
        end

        def aggregate_field_statement(aggregate_function, property, qualify)
          column_name  = if aggregate_function == :count && property.nil?
            '*'
          else
            property_to_column_name(property, qualify)
          end

          function_name = case aggregate_function
            when :count then 'COUNT'
            when :min   then 'MIN'
            when :max   then 'MAX'
            when :avg   then 'AVG'
            when :sum   then 'SUM'
            else raise "Invalid aggregate function: #{aggregate_function.inspect}"
          end

          "#{function_name}(#{column_name})"
        end

      end #module SQL
      include SQL
    end # class DataObjectsAdapter
  end # module Adapters
end # module DataMapper
