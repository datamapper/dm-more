module DataMapper
  module Adapters
    class DataObjectsAdapter
      def count(repository, query)
        parameters = []
        parameters = query.conditions.collect { |condition| condition.last }
        row_count = query(count_statement(query),*parameters).first.to_i
      end
      module SQL
        def count_statement(query)
          qualify = query.links.any?

          sql = "SELECT COUNT(*) as row_count"

          sql << " FROM " << quote_table_name(query.model_name)

          unless query.conditions.empty?
            sql << " WHERE "
            sql << "(" << query.conditions.map do |operator, property, value|
              model_name = property.model.storage_name(query.repository.name) if property && property.respond_to?(:model)
              case operator
                when String then operator
                when :eql, :in then equality_operator(query, model_name,operator, property, qualify, value)
                when :not      then inequality_operator(query, model_name,operator, property, qualify, value)
                when :like     then "#{property_to_column_name(model_name, property, qualify)} LIKE ?"
                when :gt       then "#{property_to_column_name(model_name, property, qualify)} > ?"
                when :gte      then "#{property_to_column_name(model_name, property, qualify)} >= ?"
                when :lt       then "#{property_to_column_name(model_name, property, qualify)} < ?"
                when :lte      then "#{property_to_column_name(model_name, property, qualify)} <= ?"
                else raise "CAN HAS CRASH?"
              end
            end.join(') AND (') << ")"
          end

          sql << " LIMIT #{query.limit}" if query.limit
          sql << " OFFSET #{query.offset}" if query.offset && query.offset > 0

          sql
        rescue
          DataMapper.logger.error("QUERY INVALID: #{query.inspect}")
          raise $!
        end
      end #module SQL
      include SQL
    end
  end
end
