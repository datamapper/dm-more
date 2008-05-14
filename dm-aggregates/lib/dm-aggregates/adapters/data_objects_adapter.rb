module DataMapper
  module Adapters
    class DataObjectsAdapter
      def count(repository, property, query)
        parameters = query.parameters
        row_count =  query(count_statement(property, query), *parameters).first.to_i
      end

      def min(respository, property, query)
        parameters = query.parameters
        min = query(aggregate_value_statement(property, :min, query), *parameters).first
      end

      def max(respository, property, query)
        parameters = query.parameters
        max = query(aggregate_value_statement(property, :max, query), *parameters).first
      end

      def avg(respository, property, query)
        parameters = query.parameters
        avg = query(aggregate_value_statement(property, :avg, query), *parameters).first
      end

      def sum(respository, property, query)
        parameters = query.parameters
        sum = query(aggregate_value_statement(property, :sum, query), *parameters).first
      end

      module SQL
        private

        def count_statement(property, query)
          qualify      = query.links.any?
          storage_name = query.model.storage_name(query.repository.name)
          column_name  = property.nil? ? '*' : property_to_column_name(storage_name, property, qualify)

          statement = "SELECT COUNT(#{column_name}) as row_count"

          statement << ' FROM ' << quote_table_name(storage_name)

          unless query.conditions.empty?
            statement << ' WHERE '
            statement << '(' if query.conditions.size > 1
            statement << query.conditions.map do |operator, property, bind_value|
              storage_name = property.model.storage_name(query.repository.name) if property && property.respond_to?(:model)
              case operator
                when :raw      then property
                when :eql, :in then equality_operator(query, storage_name,operator, property, qualify, bind_value)
                when :not      then inequality_operator(query, storage_name,operator, property, qualify, bind_value)
                when :like     then "#{property_to_column_name(storage_name, property, qualify)} LIKE ?"
                when :gt       then "#{property_to_column_name(storage_name, property, qualify)} > ?"
                when :gte      then "#{property_to_column_name(storage_name, property, qualify)} >= ?"
                when :lt       then "#{property_to_column_name(storage_name, property, qualify)} < ?"
                when :lte      then "#{property_to_column_name(storage_name, property, qualify)} <= ?"
                else raise "Invalid query operator: #{operator.inspect}"
              end
            end.join(') AND (')
            statement << ')' if query.conditions.size > 1
          end

          statement << " LIMIT #{query.limit}" if query.limit
          statement << " OFFSET #{query.offset}" if query.offset && query.offset > 0

          statement
        rescue => e
          DataMapper.logger.error("QUERY INVALID: #{query.inspect} (#{e})")
          raise e
        end

        def aggregate_value_statement(property, aggregate_function, query)
          qualify       = query.links.any?
          storage_name  = query.model.storage_name(query.repository.name)
          column_name   = property_to_column_name(storage_name, property, qualify)
          function_name = case aggregate_function
            when :min then 'MIN'
            when :max then 'MAX'
            when :avg then 'AVG'
            when :sum then 'SUM'
            else raise "Invalid aggregate function: #{aggregate_function.inspect}"
          end

          statement = "SELECT #{function_name}(#{column_name}) as row_count"
          statement << ' FROM ' << quote_table_name(storage_name)

          unless query.conditions.empty?
            statement << ' WHERE '
            statement << '(' if query.conditions.size > 1
            statement << query.conditions.map do |operator, property, bind_value|
              storage_name = property.model.storage_name(query.repository.name) if property && property.respond_to?(:model)
              case operator
                when :raw      then property
                when :eql, :in then equality_operator(query, storage_name,operator, property, qualify, bind_value)
                when :not      then inequality_operator(query, storage_name,operator, property, qualify, bind_value)
                when :like     then "#{property_to_column_name(storage_name, property, qualify)} LIKE ?"
                when :gt       then "#{property_to_column_name(storage_name, property, qualify)} > ?"
                when :gte      then "#{property_to_column_name(storage_name, property, qualify)} >= ?"
                when :lt       then "#{property_to_column_name(storage_name, property, qualify)} < ?"
                when :lte      then "#{property_to_column_name(storage_name, property, qualify)} <= ?"
                else raise "Invalid query operator: #{operator.inspect}"
              end
            end.join(') AND (')
            statement << ')' if query.conditions.size > 1
          end

          statement << " LIMIT #{query.limit}" if query.limit
          statement << " OFFSET #{query.offset}" if query.offset && query.offset > 0

          statement
        rescue => e
          DataMapper.logger.error("QUERY INVALID: #{query.inspect} (#{e})")
          raise e
        end

      end #module SQL
      include SQL
    end # class DataObjectsAdapter
  end # module Adapters
end # module DataMapper
