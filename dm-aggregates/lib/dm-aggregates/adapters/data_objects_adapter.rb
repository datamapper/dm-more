module DataMapper
  module Adapters
    class DataObjectsAdapter
      def count(repository, query)
        parameters = []
        parameters = query.conditions.collect { |condition| condition.last }
        row_count =  query(count_statement(query), *parameters).first.to_i
      end

      module SQL
        def count_statement(query)
          qualify = query.links.any?

          statement = 'SELECT COUNT(*) as row_count'

          statement << ' FROM ' << quote_table_name(query.model.storage_name(query.repository.name))

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
    end
  end
end
